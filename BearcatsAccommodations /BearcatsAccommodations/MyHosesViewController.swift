//
//  MyHosesViewController.swift
//  BearcatsAccommodations
//
//  Created by Prashanthi Rayala  on 11/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class MyHosesViewController: UIViewController {

    @IBOutlet var MainView: UIView!
    @IBOutlet var noRecordLbl: UILabel!
    @IBOutlet var housesTV: UITableView!
    
    let db = Firestore.firestore()
    var housesList: [HouseModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        housesTV.delegate = self
        housesTV.dataSource = self
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.hidesBackButton = false
        self.navigationItem.title = "My Houses"
        
        self.getAllHouses()
//        startBackgroundImageAnimation()
    }
    
    func getAllHouses() -> Void {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection("Houses")
            .whereField("user_id", isEqualTo: id)
        
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
                    
                    self.housesList.append(h)
                    
                    
                }
                
                self.noRecordLbl.isHidden = true
                if self.housesList.count == 0 {
                    
                    self.noRecordLbl.isHidden = false
                }
                
                self.housesTV.reloadData()
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
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AddHouseViewController") as! AddHouseViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
}


extension MyHosesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.housesList.count
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
    
    
    
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "MyHouseDetailsSegue", sender: indexPath)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "MyHouseDetailsSegue",
//            let indexPath = sender as? IndexPath,
//            let destinationVC = segue.destination as? HouseDetailsViewController {
//            
//            let selectedHouse = housesList[indexPath.row]
//            destinationVC.house = selectedHouse
//        }
//    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        cell.transform = CGAffineTransform(translationX: -cell.bounds.width, y: 0)

        UIView.animate(withDuration: 0.8, delay: 0.1 * Double(indexPath.row), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .curveEaseInOut, animations: {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1.0
        }, completion: nil)
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let house = self.housesList[indexPath.row]
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HouseDetailsViewController") as! HouseDetailsViewController
        obj.house = house
        self.navigationController!.pushViewController(obj, animated: true)
    }
   
    
}
