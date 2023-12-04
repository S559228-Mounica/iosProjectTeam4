//
//  AddHouseViewController.swift
//  BearcatsAccommodations
//
//  Created by Aashritha Dodda on 11/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import AVKit


class AddHouseViewController: UIViewController {

    @IBOutlet weak var houseIV: UIImageView!
    
    @IBOutlet weak var cityTF: UITextField!
    
    @IBOutlet weak var addressTF: UITextField!
    
    @IBOutlet weak var areaTF: UITextField!
    
    @IBOutlet weak var bedroomsTF: UITextField!
    
    @IBOutlet weak var bathroomsTF: UITextField!
    
    @IBOutlet weak var contactTF: UITextField!
    
    
    @IBOutlet var cameraBtn: UIButton!
    var images: [UIImage] = []
    var imagesURL: [String] = []
    
    
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        swipeLeft.direction = .left
        self.houseIV.addGestureRecognizer(swipeLeft)
        
        //let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        //swipeRight.direction = .right
        //self.houseIV.addGestureRecognizer(swipeRight)
        
    }
    
    
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
        
        if images.count == 0 {
            
            self.view.makeToast("Please select at lease 1 image")
            return
        }
        
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
        UploadImages.saveImages(imagesArray: self.images) { arr in
            
            self.alert?.dismiss(animated: true)
            self.imagesURL = arr
            
            self.uploadHouse()
        }
        
        
        
    }
    
    func uploadHouse() -> Void {
        
        var str = ""
        for url in imagesURL {
            
            str = String(format: "%@%@,", str, url)
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

        db.collection(path).document().setData(params) { err in
            if let err = err {

                self.alert?.dismiss(animated: true)
                self.showErrorAlert(error: err.localizedDescription)

            } else {

                self.alert?.dismiss(animated: true)
                let alert = UIAlertController(title: "", message: "House added successfully", preferredStyle: UIAlertController.Style.alert)
                AudioServicesPlaySystemSound(1053)
                
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


extension AddHouseViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
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
