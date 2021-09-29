//
//  EventDetailsVC.swift
//  SYWM
//
//  Created by Maninder Singh on 04/04/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit
import GoogleMaps

class EventDetailsVC: BaseVC {

    //MARK:- IBOutlets
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var mapView: GoogleMapView!
    @IBOutlet weak var endDate: UILabel!
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    //MARK:- Variables
    var events = Event()
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            if let styleURL = Bundle.main.url(forResource: "styled_map", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                print("Unable to find style.json")
            }
        } catch {
            print("The style definition could not be loaded: \(error)")
        }
        var bounds = GMSCoordinateBounds()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let gmsMarker1 = GMSMarker()
        let latLong1 = CLLocationCoordinate2D(latitude: appDelegate.currentLatLong.coordinate.latitude, longitude: appDelegate.currentLatLong.coordinate.longitude)
        gmsMarker1.position = latLong1
        gmsMarker1.map = self.mapView
        bounds = bounds.includingCoordinate(gmsMarker1.position)
        let gmsMarker = GMSMarker()
        let latLong = CLLocationCoordinate2D(latitude: events.latitude, longitude: events.longitude)
        gmsMarker.position = latLong
        gmsMarker.icon = #imageLiteral(resourceName: "ON MAP - USER PICTURE PIN")
        gmsMarker.map = self.mapView
        bounds = bounds.includingCoordinate(gmsMarker.position)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60)
        self.mapView.animate(with: update)
        
        self.eventName.text = self.events.name
        self.desc.text = self.events.descrip
        
//        self.eventName.text = self.events.descrip
//        self.desc.text = self.events.name
        self.locationLabel.text = self.events.location
            //+ ", " + self.events.country
        
        let startD = Date(timeIntervalSince1970: self.events.startDate/1000.0)
        let endD = Date(timeIntervalSince1970: self.events.endDate/1000.0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy \n hh:mm a"
        self.startDate.text = dateFormatter.string(from: startD)
        self.endDate.text = dateFormatter.string(from: endD)
    }
    
    //MARK:- IBActions
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swymButton(_ sender: Any) {
        let id = self.events.id
        
        let currentLocation = (UIApplication.shared.delegate as! AppDelegate).currentLatLong
        let eventLatLong = CLLocation(latitude: self.events.latitude, longitude: self.events.longitude)
        let distance = eventLatLong.distance(from: currentLocation)
        if distance > 500{
            self.showAlert(message: "“You need to be at the location noted in order to join this SWYM’ing pool.")
            return
        }
        self.showAlert(message: "Are you sure you want to join this event?", title: "", otherButtons: ["Yes": {_ in
            self.joinPoolOrLeavePool(params: ["swymEventId" : id, "activityStatus": "SWYMMING"], swymStart: true)
            }], cancelTitle: "No", cancelAction: nil)
    }
    
    //MARK:- Custom Methods

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
            let VC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "SwymerVC") as! SwymerVC
            VC.poolId = params["swymEventId"] as? Int ?? 0
            self.navigationController?.pushViewController(VC, animated: true)
        }
    }
    

}
