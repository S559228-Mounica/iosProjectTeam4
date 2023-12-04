//
//  EditHouseViewController.swift
//  BearcatsAccommodations
//
//  Created by Bhargav Krishna Moparthy on 11/30/23.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import AVKit


class EditHouseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  

    @IBOutlet weak var houseIV: UIImageView!
    
    @IBOutlet weak var cityTF: UITextField!
    
    @IBOutlet weak var addressTF: UITextField!
    
    @IBOutlet weak var areaTF: UITextField!
    
    @IBOutlet weak var bedroomsTF: UITextField!
    
    @IBOutlet weak var bathroomsTF: UITextField!
    
    @IBOutlet weak var contactTF: UITextField!
    
    
    @IBOutlet weak var ImgCollection: UICollectionView!
    @IBOutlet var cameraBtn: UIButton!
    var images: [UIImage] = []
    var imagesURL: [String] = []
//    before
    var houseid:String?
    var user_id: String?
    var user_name: String?
    var city: String?
    var address: String?
    var area: String?
    var bedrooms: String?
    var bathrooms: String?
    var contact: String?
    var imagesOld: [String] = []
    

    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cityTF.text = city!
        addressTF.text = address!
        areaTF.text = area!
        bedroomsTF.text = bedrooms!
        bathroomsTF.text = bathrooms!
        contactTF.text = contact!
        imagesURL = imagesOld
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        self.houseIV.addGestureRecognizer(swipeLeft)
//        images colleciton
        ImgCollection.dataSource = self
        ImgCollection.delegate = self
        //let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        //swipeRight.direction = .right
        //self.houseIV.addGestureRecognizer(swipeRight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesOld.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = ImgCollection.dequeueReusableCell(withReuseIdentifier: "imgcell", for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        cell.Img.layer.cornerRadius = 12
        cell.Img.clipsToBounds = true
        
        let url = self.imagesOld[indexPath.item]
        cell.Img.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "loading"))
               // Configure the cell with the image from the URL
               // You'll need to implement a method to load the image from the URL into the cell's image view

               return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showDeleteConfirmationAlert(at: indexPath.item)
    }

    func showDeleteConfirmationAlert(at index: Int) {
        let alert = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image?", preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.removeImage(at: index)
            AudioServicesPlaySystemSound(1109)
        }
        alert.addAction(deleteAction)

        present(alert, animated: true, completion: nil)
    }

    func removeImage(at index: Int) {
        imagesOld.remove(at: index)

        ImgCollection.performBatchUpdates({
            ImgCollection.deleteItems(at: [IndexPath(item: index, section: 0)])
        }, completion: nil)
    }

//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//        removeImage(at: indexPath.item)
//    }
//
//    func removeImage(at index: Int) {
//
//        imagesOld.remove(at: index)
//
//
//        ImgCollection.reloadData()
//    }
    @objc func handleSwipeLeft() {
        print("Swiped left!")
    }
    
    @objc func handleSwipeRight() {
        print("Swiped right!")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func selectImgeBtn(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        self.present(pickerController, animated: true)
    }
    
    
    @IBAction func saveBtn(_ sender: Any) {
        
//        if images.count == 0 {
//            
//            self.view.makeToast("Please select at lease 1 image")
//            return
//        }
        
        if cityTF.text == "" {
            
            self.view.makeToast("Please enter city name")
            return
        }
        
        if addressTF.text == "" {
            
            self.view.makeToast("Please enter Address")
            return
        }
        
        if areaTF.text == "" {
            
            self.view.makeToast("Please enter area")
            return
        }
        
        if bedroomsTF.text == "" {
            
            self.view.makeToast("Please enter total bedrooms")
            return
        }
        
        if bathroomsTF.text == "" {
            
            self.view.makeToast("Please enter total bathrooms")
            return
        }
        
        if contactTF.text == "" {
            
            self.view.makeToast("Please enter contact number")
            return
        }
        
        self.showLoader()
        
        if images.count > 0 {

            UploadImages.saveImages(imagesArray: self.images) { arr in
                
                self.alert?.dismiss(animated: true)
                self.imagesURL = arr
                
                self.uploadHouse()
            }
        }
        else{
            self.uploadHouse()

        }
      
        
        
        
    }
    
    func uploadHouse() -> Void {
        
        var str = ""
        if(images.count > 0){
            for url in imagesURL {
                
                str = String(format: "%@%@,", str, url)
            }
        }
        for ourl in imagesOld{
            str = String(format: "%@%@,", str, ourl)
        }
       
        str.removeLast()
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let params = ["user_id": id,
                      "user_name": name,
                      "city": cityTF.text!,
                      "address": addressTF.text!,
                      "area": areaTF.text!,
                      "bedrooms": bedroomsTF.text!,
                      "bathrooms": bathroomsTF.text!,
                      "contact": contactTF.text!,
                      "images": str]


        let path = String(format: "%@", "Houses")
        let db = Firestore.firestore()

        db.collection(path).document(houseid!).updateData(params) { err in
            if let err = err {
                print("error")
                self.alert?.dismiss(animated: true)
                self.showErrorAlert(error: err.localizedDescription)
            } else {
                print("No Error")
                self.alert?.dismiss(animated: true)
                
                let alert = UIAlertController(title: "", message: "House updated successfully", preferredStyle: UIAlertController.Style.alert)
                AudioServicesPlaySystemSound(1109)

                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.destructive, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))

                self.present(alert, animated: true, completion: nil)
            }
        }
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
    
    
    func showErrorAlert(error: String) -> Void {
        let alert = UIAlertController(title: "", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension EditHouseViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage

        if let image = image {
            
            self.images.append(image)
            self.houseIV.image = image
            
            self.cameraBtn.setImage(UIImage(systemName: "plus"), for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
