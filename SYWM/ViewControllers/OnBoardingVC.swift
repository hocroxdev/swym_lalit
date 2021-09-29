//
//  OnBoardingVC.swift
//  SYWM
//
//  Created by Maninder Singh on 02/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import UIKit

class OnBoardingVC: BaseVC {

    //MARK:- IBOutlets
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    //MARK:- Variables
    var currentIndex = 0
    var headerText1 = ["Out of any widely attended event allowing you to search, match, and meet with other users attending the same event as you!","Wading into the deep waters of dating is so much easier with SWYM. You cut out the awkwardness of the first encounter and match with interested users at your event.","- Avoid the process of elimination/searching that naturally occurs in social settings\n\n- More efficient use of social time\n\n- Eliminates the mundane exchange of messages\n\n-Intertwines connecting through an app and the act of meeting someone face to face!\n\n- Turn any widely attended event into a first date!"]
    var headerText2 = ["SWYM Creates a Dating Pool","SWYM The Ultimate Icebreaker","SWYM Provides Many Benefits!"]
    
    //MARK:- VC Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        logAnalytics(id: FirebaseEvent.GET_STARTED, parameters: nil)
    }
    
    //MARK:- IBActions
    @IBAction func nextButton(_ sender: Any) {
        logAnalytics(id: FirebaseEvent.LOGIN_CLICKED, parameters: nil)
        let indexIndex = currentIndex + 1
        if indexIndex == 3{
            let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
            self.navigationController?.pushViewController(VC, animated: true)
            return
        }
        if indexIndex < 3{
            self.collectionView.scrollToItem(at: IndexPath(item: indexIndex, section: 0), at: .centeredHorizontally, animated: true)
            self.pageControl.currentPage = indexIndex
            self.currentIndex = indexIndex
            if currentIndex < 2{
                self.nextButton.setTitle("NEXT", for: .normal)
                self.nextButton.backgroundColor = UIColor(red: 49.0/255.0, green: 94.0/255.0, blue: 172.0/255.0, alpha: 1)
            }else{
                self.nextButton.setTitle("GET STARTED", for: .normal)
                self.nextButton.backgroundColor = UIColor(red: 217.0/255.0, green: 64.0/255.0, blue: 99.0/255.0, alpha: 1)
            }
        }
    }
    
    
    //MARK:- Custom Methods


}

extension OnBoardingVC : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnBoardingCell", for: indexPath) as! OnBoardingCell
        if indexPath.item == 0{
            cell.backImage.image = #imageLiteral(resourceName: "Slide 1")
            cell.onboardingLabel.textAlignment = .center
        }
        if indexPath.item == 1{
            cell.backImage.image = #imageLiteral(resourceName: "Slide 2")
            cell.onboardingLabel.textAlignment = .center
        }
        if indexPath.item == 2{
            cell.backImage.image = #imageLiteral(resourceName: "Slide 3")
            cell.onboardingLabel.textAlignment = .left
        }
        
        cell.headerLabel.text = headerText2[indexPath.item]
        cell.onboardingLabel.text = headerText1[indexPath.item]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        pageControl.currentPage = indexPath.item
        currentIndex = indexPath.item
        if currentIndex < 2{
            self.nextButton.setTitle("NEXT", for: .normal)
            self.nextButton.backgroundColor = UIColor(red: 49.0/255.0, green: 94.0/255.0, blue: 172.0/255.0, alpha: 1)
        }else{
            self.nextButton.setTitle("GET STARTED", for: .normal)
            self.nextButton.backgroundColor = UIColor(red: 217.0/255.0, green: 64.0/255.0, blue: 99.0/255.0, alpha: 1)
        }
    }
    
    
}

class OnBoardingCell : UICollectionViewCell{
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var onboardingLabel: UILabel!
    @IBOutlet weak var backImage: UIImageView!
    
}
