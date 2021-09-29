//
//  HomeVC.swift
//  SYWM
//
//  Created by Maninder Singh on 04/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import NVActivityIndicatorView
import SDWebImage

class HomeVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var mapButtons: UIStackView!
    @IBOutlet weak var noEventView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mapView: GoogleMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var swymStatus: UIButton!
    @IBOutlet weak var joinEventNamelabel: UILabel!
    @IBOutlet weak var leavePoolview: UIView!
    @IBOutlet weak var searchEventStackView: UIStackView!
    @IBOutlet weak var currentIcon: UIButton!
    @IBOutlet weak var plusIcon: UIButton!
    @IBOutlet weak var minusIcon: UIButton!
    
    
    //MARK:- Variables
    let locationManager = CLLocationManager()
    var currentLatLong = CLLocation(latitude: 0.0, longitude: 0.0)
    var currentZoom : Float = 0.0
    var activityData = ActivityData()
    var currentEvent = Event()
    var currentMarker = GMSMarker()
    var events = [Event]()
    var timer = Timer()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        let whiteImage = UIImage(color: UIColor.white, size: CGSize(width: searchBar.layer.frame.width, height: searchBar.layer.frame.height))
        searchBar.setSearchFieldBackgroundImage(whiteImage, for: .normal)
//        searchBar.setTextField(color: UIColor.black.withAlphaComponent(1))
        setmap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserDetail()
        activeEvents()
    }
    
    //MARK:- IBActions
    @IBAction func editButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "ChatListVC") as! ChatListVC
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    @IBAction func sideMenuButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "OptionsVC") as! OptionsVC
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func plusButton(_ sender: Any) {
        if currentZoom == 18{
            return
        }
        currentZoom += 0.5
        mapView.animate(toZoom: currentZoom)

    }
    @IBAction func refreshButton(_ sender: Any) {
        self.getEvents()
    }
    
    @IBAction func minusButton(_ sender: Any) {
        if currentZoom == 0{
            return
        }
        currentZoom -= 0.5
        mapView.animate(toZoom: currentZoom)
    }
    
    @IBAction func leavePoolButton(_ sender: Any) {
        self.showAlert(message: "Are you sure you want to leave this pool?", title: "", otherButtons: ["Yes": {_ in
            self.joinPoolOrLeavePool(params: ["swymEventId" : self.currentEvent.id, "activityStatus": "NOT_SWYMMING"], swymStart: false)
            }], cancelTitle: "No", cancelAction: nil)
    }
    
    @IBAction func hangOutPoolButton(_ sender: Any) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerVC") as! SwymerVC
        VC.poolId = currentEvent.id
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func currentLocationButton(_ sender: Any) {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("off")
                self.gotoPhonePrivacy()
            case .authorizedAlways, .authorizedWhenInUse:
                UIView.animate(withDuration: 0.25, animations: {
                    self.locationManager.startUpdatingLocation()
                    self.view.layoutIfNeeded()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    
                    self.currentMarker.position = appDelegate.currentLatLong.coordinate
                    self.mapView.camera  = GMSCameraPosition(target: appDelegate.currentLatLong.coordinate, zoom: 12, bearing: 0, viewingAngle: 0)
                    
                })
            }
        } else {
            gotoPhonePrivacy()
            print("on")
        }
    }
    
    @objc func update(){
        guard self.currentEvent.id != 0 else { return }
        let currentLocation = (UIApplication.shared.delegate as! AppDelegate).currentLatLong
        let eventLatLong = CLLocation(latitude: self.currentEvent.latitude, longitude: self.currentEvent.longitude)
        let distance = eventLatLong.distance(from: currentLocation)
        if distance < 500 && distance > 400{
            self.showAlert(message: "You are traveled outside the range of the current pool, go back if you would like to continue Swym'ing.", title: "HOPE YOU ENJOYED!!!", otherButtons: ["Leave The Pool": {_ in
                    self.joinPoolOrLeavePool(params: ["swymEventId" : self.currentEvent.id, "activityStatus": "NOT_SWYMMING"], swymStart: false)
                }], cancelTitle: "Continue", cancelAction: nil)
            return
        }
        if distance > 500{
            self.showAlert(message: "You are about to leave your current SWYM event. You will be remove from the pool.", title: "GO BACK TO THE POOL!", otherButtons: nil, cancelTitle: "Ok") { (_) in
                self.joinPoolOrLeavePool(params: ["swymEventId" : self.currentEvent.id, "activityStatus": "NOT_SWYMMING"], swymStart: false)
            }
            return
        }
    }
    
    func gotoPhonePrivacy() {
        self.showAlert(message: "Turn on location services so we can determine your current location.", title: "SWYM", otherButtons: ["Open" : { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
            }], cancelTitle: "Cancel", cancelAction: nil)
    }
    
    
    //MARK:- Custom Methods

    func setmap(){
        do {
            if let styleURL = Bundle.main.url(forResource: "styled_map", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("The style definition could not be loaded: \(error)")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.currentLatLong = appDelegate.currentLatLong
        self.currentMarker.position = self.currentLatLong.coordinate
        self.currentMarker.map = self.mapView
        self.mapView.camera  = GMSCameraPosition(target: self.currentLatLong.coordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        mapView.settings.myLocationButton = false
        mapView.settings.zoomGestures = false
        mapView.settings.scrollGestures = false
        mapView.settings.rotateGestures = false
        self.currentIcon.isHidden = true
        self.plusIcon.isHidden = true
        self.minusIcon.isHidden = true
        mapView.delegate = self
    }
}

extension HomeVC {
    
    func activeEvents(){
        APIManager1.share.getCheckActivePool(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                self.getEvents()
                self.timer.invalidate()
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            if let jsonDict = data as? JSONDictionary{
                self.currentEvent = EventVM.shared.parseSingleEventsResponse(data: jsonDict)
                self.leavePoolview.isHidden = false
                self.searchEventStackView.isHidden = true
                self.joinEventNamelabel.text = "You are currently Swym'ing at\n \(self.currentEvent.name)"
                
                let lat = jsonDict["latitude"] as? Double ?? 0.0
                let long = jsonDict["longitude"] as? Double ?? 0.0
                
                self.mapView.clear()
                
                var bounds = GMSCoordinateBounds()
                let markerCurrent = GMSMarker()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                markerCurrent.position = appDelegate.currentLatLong.coordinate
                markerCurrent.map = self.mapView
                bounds = bounds.includingCoordinate(markerCurrent.position)
                let destMarker = GMSMarker()
                destMarker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                destMarker.icon = #imageLiteral(resourceName: "ON MAP - USER PICTURE PIN")
                destMarker.map = self.mapView
                bounds = bounds.includingCoordinate(destMarker.position)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
                self.mapView.animate(with: update)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            
        }
    }
    
    func joinPoolOrLeavePool(params: [String: Any], swymStart: Bool){
        APIManager1.share.getJoinOrLeaveEvent(indicatorReq: true, params: params) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            self.activeEvents()
            if swymStart{
                let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerVC") as! SwymerVC
                VC.poolId = params["swymEventId"] as? Int ?? 0
                self.navigationController?.pushViewController(VC, animated: true)
            }else{
                self.leavePoolview.isHidden = true
                self.searchEventStackView.isHidden = false
                self.noEventView.isHidden = false
            }
        }
    }
    
    func getEvents(){
        EventVM.shared.evetns.removeAll()
        self.events.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //31.337840999999997      ----appDelegate.currentLatLong.coordinate.latitude
//        75.3519783----- appDelegate.currentLatLong.coordinate.longitude
        APIManager1.share.getEvents(lat: appDelegate.currentLatLong.coordinate.latitude, long: appDelegate.currentLatLong.coordinate.longitude, indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            EventVM.shared.parseGetEventsResponse(response: data as! JSONArray)
            var bounds = GMSCoordinateBounds()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            bounds = bounds.includingCoordinate(appDelegate.currentLatLong.coordinate)
            self.events = EventVM.shared.evetns
            for marker in self.events{
                let gmsMarker = GMSMarker()
                let latLong = CLLocationCoordinate2D(latitude: marker.latitude, longitude: marker.longitude)
                gmsMarker.position = latLong
                gmsMarker.icon = #imageLiteral(resourceName: "ON MAP - USER PICTURE PIN")
                gmsMarker.map = self.mapView
                bounds = bounds.includingCoordinate(gmsMarker.position)
            }
            let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
            self.mapView.animate(with: update)
            
            if self.events.count > 0{
                self.tableView.isHidden = false
                self.noEventView.isHidden = true
            }else{
                self.tableView.isHidden = true
                self.noEventView.isHidden = false
            }
            self.tableView.reloadData()
        }
    }
    
    func getUserDetail(){
        
        APIManager1.share.getProfile(indicatorReq: true, params: nil) { (data, error, serverError) in
            if error != nil{
                return
            }
            if serverError != nil{
                
                if let server = serverError as? NSDictionary{
                    self.showAlert(message: server["title"] as? String ?? "")
                }
                return
            }
            let photo = UserVM.shared.userDict?.photosArray.first
            self.userImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.userImageView.sd_setImage(with: URL(string: photo?["photoThumbUrl"] as? String ?? ""), placeholderImage: nil, options: [], context: nil)
            self.nameLabel.text = UserVM.shared.userDict?.firstName ?? ""
            let heightInches = Int(UserVM.shared.userDict?.height ?? 0)
            let cm = 2.54 * Double(heightInches)
            let v = self.showFootAndInchesFromCm(Double(cm))
            let age = UserVM.shared.userDict?.age ?? 0
            self.swymStatus.setTitle("\(age), \(v)", for: .normal)
        }
        
    }
    
    func showFootAndInchesFromCm(_ cms: Double) -> String {
        let feet = cms * 0.0328084
        let feetShow = Int(floor(feet))
        let feetRest: Double = ((feet * 100).truncatingRemainder(dividingBy: 100) / 100)
        let inches = Int(floor(feetRest * 12))
        return "\(feetShow)' \(inches)\""
    }
}

extension HomeVC : GMSMapViewDelegate{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        currentZoom = mapView.camera.zoom
    }
}


extension HomeVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell") as! HomeCell
        cell.selectionStyle = .none
        let object = self.events[indexPath.row]
        cell.poolName.text = object.name
        cell.swymButton.tag = indexPath.row
        cell.swymButton.addTarget(self, action: #selector(self.swymAction(_:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as! EventDetailsVC
        VC.events = self.events[indexPath.row]
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc func swymAction(_ sender: UIButton){
        let index = sender.tag
        let id = self.events[index].id
        self.currentEvent = self.events[index]
        
        let currentLocation = (UIApplication.shared.delegate as! AppDelegate).currentLatLong
        let eventLatLong = CLLocation(latitude: self.currentEvent.latitude, longitude: self.currentEvent.longitude)
        let distance = eventLatLong.distance(from: currentLocation)
        if distance > 500{
            self.showAlert(message: "Please go inside the pool to join this event.")
            return
        }
        self.showAlert(message: "Are you sure you want to join this event?", title: "", otherButtons: ["Yes": {_ in
            self.joinPoolOrLeavePool(params: ["swymEventId" : id, "activityStatus": "SWYMMING"], swymStart: true)
            }], cancelTitle: "No", cancelAction: nil)
    }
}

class HomeCell : UITableViewCell{
    
    @IBOutlet weak var swymButton: UIButton!
    @IBOutlet weak var poolName: UILabel!
    
}

extension HomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            gotoPhonePrivacy()
            break
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLatLong = location
            locationManager.stopUpdatingLocation()
        }
    }
}




extension HomeVC: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.events = EventVM.shared.evetns.filter({ return $0.name.lowercased().contains(searchBar.text?.lowercased() ?? "")})
        if searchBar.text == ""{
            self.events = EventVM.shared.evetns
        }
        self.tableView.reloadData()
    }
    
    
    
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.searchBar.text = ""
            self.events = EventVM.shared.evetns
            self.tableView.reloadData()
        }
    }

    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}

class GoogleMapView : GMSMapView {
    
}

public extension UIImage {
  public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
    let rect = CGRect(origin: .zero, size: size)
     UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
     color.setFill()
     UIRectFill(rect)
     let image = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     guard let cgImage = image?.cgImage else { return nil }
     self.init(cgImage: cgImage)
} }
