//
//  HousesListViewController.swift
//  BearcatsAccommodations
//
//  Created by Mounica Seelam on 11/05/2023.
//

import UIKit
import FirebaseFirestore
import SDWebImage
import FirebaseAuth
import AVKit

class HousesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var noRecordLbl: UILabel!
    @IBOutlet var menuView: UIStackView!
    
    @IBOutlet weak var filterTF: UITextField!
    let db = Firestore.firestore()
    var housesList: [HouseModel] = []
    var filteredHouses: [HouseModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Houses"
        
        self.getAllHouses()
        
        let menu = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease"), style: .plain, target: self, action: #selector(menuTapped))
        navigationItem.leftBarButtonItem = menu
        //let logout = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(LogoutTapped))
        //navigationItem.rightBarButtonItems = [logout]
        
        menuView.layer.cornerRadius = 8
        menuView.clipsToBounds = true
    }
    
    
    @objc func menuTapped() -> Void {
        if menuView.isHidden {
            
            menuView.isHidden = false
        }else {
            
            menuView.isHidden = true
        }
    }
  
    func LogoutTapped() -> Void {
        
        do {
            try Auth.auth().signOut()
        } catch {}
        
        
        self.navigationController?.navigationBar.isHidden = true
        //  self.performSegue(withIdentifier: "loginVC", sender: self)
        
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    @IBAction func filterFunc(_ sender: Any) {
        getAllHouses()
    }
    
    
    @IBAction func resetBtn(_ sender: Any) {
        filterTF.text = ""
        getAllHouses()
    }
    func getAllHouses() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection("Houses")
            .whereField("user_id", isNotEqualTo: id)
        
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
                
            } else {
                
                self.housesList.removeAll()
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    var h = HouseModel()
                    h.id = document.documentID
                    h.user_id = data["user_id"] as? String ?? ""
                    h.user_name = data["user_name"] as? String ?? ""
                    h.city = data["city"] as? String ?? ""
                    h.address = data["address"] as? String ?? ""
                    h.area = data["area"] as? String ?? ""
                    h.bedrooms = data["bedrooms"] as? String ?? ""
                    h.bathrooms = data["bathrooms"] as? String ?? ""
                    h.contact = data["contact"] as? String ?? ""
                    
                    let str = data["images"] as? String ?? ""
                    let arr = str.components(separatedBy: ",")
                    h.images = arr
                    if(self.filterTF.text! != ""){
                        
                        
                        if let doubleValue = Double(h.bedrooms!) {
                            print("Double value: \(doubleValue)")
                            
                            if let filterval = Double(self.filterTF.text!) {
                                print("Filter value: \(filterval)")
                                if(doubleValue == Double(filterval)){
                                    self.housesList.append(h)
                                }
                                
                            } else {
                                
                                self.showAlert(message: "Invalid Value, resetting Filter")
                                self.filterTF.text = ""
                                self.housesList.append(h)
                            }
                        } else {
                            print("Invalid Double value")
                        }
                        
                        
                    }
                    else{
                        self.housesList.append(h)
                    }
                }
                
                self.noRecordLbl.isHidden = true
                if self.housesList.count == 0 {
                    
                    self.noRecordLbl.isHidden = false
                }
                
                self.tableView.reloadData()
                if(self.housesList.count == 0){
                    self.showAlert(message: "No houses available")
                    AudioServicesPlaySystemSound(1152)
                    print(self.housesList.count)
                    self.filterTF.text = "Enter Number"
                    self.getAllHouses()
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func addBtn(_ sender: Any) {
        
        //        self.performSegue(withIdentifier: "newhouse", sender: self)
        //    }
        //
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AddHouseViewController") as! AddHouseViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
    @IBAction func chatsBtn(_ sender: Any) {
        //        self.performSegue(withIdentifier: "chats", sender: self)
        //
        //    }
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChatsListViewController") as! ChatsListViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
    @IBAction func myListBtn(_ sender: Any) {
        
        menuView.isHidden = true
        //        self.performSegue(withIdentifier: "myhouses", sender: self)
        //    }
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MyHosesViewController") as! MyHosesViewController
        self.navigationController!.pushViewController(obj, animated: true)
        
    }
        
        
        @IBAction func profileBtn(_ sender: Any) {
            
            menuView.isHidden = true
            //        self.performSegue(withIdentifier: "Myprofile", sender: self)
            //    }
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            self.navigationController!.pushViewController(obj, animated: true)
            
        }
        
        @IBAction func logoutBtn(_ sender: Any) {
            
            menuView.isHidden = true
            self.LogoutTapped()
        }
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Invalid Value", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
    }
    }
    
    
    extension HousesListViewController: UITableViewDelegate, UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.housesList.count
        }
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
              
                cell.alpha = 0.0

                UIView.animate(withDuration: 0.3, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
                    cell.alpha = 1.0
                }, completion: nil)
            }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell: HouseTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "house") as? HouseTableViewCell
            
            let house = self.housesList[indexPath.row]
            let images = house.images
            let url = images[0]
            cell.houseIV.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: ""))
            
            cell.houseIV.layer.cornerRadius = cell.houseIV.frame.size.height / 2
            cell.houseIV.clipsToBounds = true
            
            cell.cityLbl.text = house.city ?? ""
            cell.addressLbl.text = house.address ?? ""
            
            return cell
            
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            
            return 100
        }
        
        
        
        //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        performSegue(withIdentifier: "HouseDetailsSegue", sender: indexPath)
        //    }
        //
        //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        if segue.identifier == "HouseDetailsSegue" {
        //            if let indexPath = sender as? IndexPath {
        //                let house = housesList[indexPath.row]
        //                if let destinationVC = segue.destination as? HouseDetailsViewController {
        //                    destinationVC.house = house
        //                }
        //            }
        //        }
        //    }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            let house = self.housesList[indexPath.row]
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "HouseDetailsViewController") as! HouseDetailsViewController
            obj.house = house
            self.navigationController!.pushViewController(obj, animated: true)
        }
    }

