//
//  HouseDetailsViewController.swift
//  BearcatsAccommodations
//
//  Created by Prashanthi Rayala  on 11/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore


class HouseDetailsViewController: UIViewController {
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var EditHouseBTN: UIButton!
    @IBOutlet weak var imagesCV: UICollectionView!
    
    @IBOutlet weak var cityLbl: UILabel!
    
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var areaLbl: UILabel!
    
    @IBOutlet weak var bedroomsLbl: UILabel!
    
    @IBOutlet weak var bathroomsLbl: UILabel!
    @IBOutlet var previousBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
    var alert: UIAlertController?
    
    @IBOutlet var contactBtn: UIButton!
    
    @IBOutlet var chatBtn: UIButton!
    
    var house: HouseModel?
    var images: [String] = []
    
    var imageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nextBtn.isHidden = true
        previousBtn.isHidden = true
        cityLbl.text = house?.city ?? ""
        addressLbl.text = house?.address ?? ""
        areaLbl.text = house?.area ?? ""
        
        bedroomsLbl.text = house?.bedrooms ?? ""
        bathroomsLbl.text = house?.bathrooms ?? ""
        
        images = house?.images ?? []
        
        imagesCV.delegate = self
        imagesCV.dataSource = self
        
        self.previousBtn.isEnabled = false
        self.nextBtn.isEnabled = false
        
        if self.images.count > 1 {
            
            self.nextBtn.isEnabled = true
        }
        
        let id = Auth.auth().currentUser?.uid ?? ""
        if id == house?.user_id {
            EditHouseBTN.isHidden = false
            deleteBtn.isHidden = false
            contactBtn.isHidden = true
            chatBtn.isHidden = true
        }
        else{
            deleteBtn.isHidden = true
            EditHouseBTN.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func previousBtn(_ sender: Any) {
        
        
        if imageIndex > 0 {
            
            imageIndex -= 1
        }
        
        if imageIndex == 0 {
            
            self.previousBtn.isEnabled = false
        }else {
            
            self.previousBtn.isEnabled = true
        }
        
        self.imagesCV.scrollToItem(at:IndexPath(item: imageIndex, section: 0), at: .right, animated: false)
        
        if self.images.count > 0 {
            
            self.nextBtn.isEnabled = true
        }
        updateCellAppearance()
    }
    
    @IBAction func nextBtn(_ sender: Any) {
        
        if imageIndex < self.images.count - 1 {
            
            imageIndex += 1
        }
        
        if imageIndex == self.images.count - 1 {
            
            self.nextBtn.isEnabled = false
        }else {
            
            self.nextBtn.isEnabled = true
        }
        
        self.imagesCV.scrollToItem(at:IndexPath(item: imageIndex, section: 0), at: .right, animated: false)
        
        self.previousBtn.isEnabled = true
        updateCellAppearance()
    }
    
    
    @IBAction func contactBtn(_ sender: Any) {
//        performSegue(withIdentifier: "ShowChatSegue", sender: self)
//    }
    
  


        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        obj.user_ID = house?.user_id ?? ""
        obj.user_name = house?.user_name ?? ""
        
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
    @IBAction func DeleteHouse(_ sender: Any) {
        showConfirmationAlert(message: "Are you sure you want to delete this house?") { confirmed in
               if confirmed {
                  
                   let houseIdToDelete = self.house?.id ?? "" 

                   let path = String(format: "%@", "Houses")
                   let db = Firestore.firestore()

                 
                   db.collection(path).document(houseIdToDelete).delete { err in
                       if let err = err {
                           self.alert?.dismiss(animated: true)
                           self.showErrorAlert(error: err.localizedDescription)
                       } else {
                           self.alert?.dismiss(animated: true)
                           let alert = UIAlertController(title: "", message: "House deleted successfully", preferredStyle: UIAlertController.Style.alert)

                           alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: { action in
                               
                               self.navigationController?.popViewController(animated: true)
                           }))

                           self.present(alert, animated: true, completion: nil)
                       }
                   }
               }
               
           }
        

    }
    @IBAction func EditBtn(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "EditHouseViewController") as! EditHouseViewController
        obj.houseid = house?.id
        obj.city = house?.city
        obj.address = house?.address
        obj.area = house?.area
        obj.bedrooms = house?.bedrooms
        obj.bathrooms = house?.bathrooms
        obj.contact = house?.contact
        obj.imagesOld = house?.images ?? [""]
        print(house?.images ?? "nill")
        self.navigationController!.pushViewController(obj, animated: true)    }
    
    @IBAction func chatBtn(_ sender: Any) {
        
//            performSegue(withIdentifier: "ShowChatsListSegue", sender: self)
//        }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ShowChatSegue",
//           let destinationVC = segue.destination as? ChatViewController {
//            
//            destinationVC.user_ID = house?.user_id ?? ""
//            destinationVC.user_name = house?.user_name ?? ""
//        }
//            if segue.identifier == "ShowChatsListSegue",
//                let destinationVC = segue.destination as? ChatsListViewController {
//                // Optionally, you can pass any data to the destination view controller here
//            }
//        }

        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChatsListViewController") as! ChatsListViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
    func showLoader() -> Void {
        
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert?.view.addSubview(loadingIndicator)
        present(alert!, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Invalid Value", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    func showErrorAlert(error: String) -> Void {
        let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func showConfirmationAlert(message: String, completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            
            completion(true)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            
            completion(false)
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true, completion: nil)
    }
}


extension HouseDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.view.frame.size.width
        return CGSize(width: width - 120 , height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : HouseImagesCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "house", for: indexPath) as! HouseImagesCollectionViewCell
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .clear
//        
        cell.houseIV.layer.cornerRadius = 12
        cell.houseIV.clipsToBounds = true
        
        let url = self.images[indexPath.item]
        cell.houseIV.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "loading"))
        updateCellAppearance()

        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
          
           updateCellAppearance()
       }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           updateCellAppearance()
       }

    func updateCellAppearance() {
        guard let collectionView = imagesCV else { return }
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

            if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
                for cell in collectionView.visibleCells {
                    if let cellIndexPath = collectionView.indexPath(for: cell) {
                        let isCentered = indexPath == cellIndexPath
                        (cell as? HouseImagesCollectionViewCell)?.updateAppearance(isCentered: isCentered)
                    }
                }
            }
        }
}
