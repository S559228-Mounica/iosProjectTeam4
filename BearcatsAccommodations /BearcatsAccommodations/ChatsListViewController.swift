//
//  ChatsListViewController.swift
//  BearcatsAccommodations
//
//  Created by Aashritha Dodda on 11/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore



class ChatsListViewController: UIViewController {

    @IBOutlet weak var chatListTV: UITableView!
    let db = Firestore.firestore()
    
    @IBOutlet var noRecordLbl: UILabel!
    
    var allContacts: [ChatListModel] = []
    var uniqueContactsArray: [ChatListModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.chatListTV.delegate = self
        self.chatListTV.dataSource = self
        
        // Do any additional setup after loading the view.
        self.noRecordLbl.isHidden = true
        self.navigationItem.title = "Chat List"
        self.getContactList()
    }
    
    
    func getContactList() {

        let id = Auth.auth().currentUser?.uid ?? ""
        
        var chatRef = db.collection("Chats")
            .whereField("sender_id", isEqualTo: id)
        
        // Query documents where the user is the sender
        chatRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting chat list: \(error.localizedDescription)")
            } else {
                
                self.allContacts.removeAll()
                
                for document in querySnapshot!.documents {
                    let receiver = document["receiver_id"] as! String
                    if receiver != id {
                        
                        let name = document["receiver_name"] as! String
                        
                        var m = ChatListModel()
                        m.id = receiver
                        m.name = name
                        
                        self.allContacts.append(m)
                    }
                }

                
                chatRef = self.db.collection("Chats")
                    .whereField("receiver_id", isEqualTo: id)
                chatRef.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting chat list: \(error.localizedDescription)")
                    } else {
                        for document in querySnapshot!.documents {
                            let sender = document["sender_id"] as! String
                            if sender != id {
                                
                                let name = document["sender_name"] as! String
                                
                                var m = ChatListModel()
                                m.id = sender
                                m.name = name
                                
                                self.allContacts.append(m)
                            }
                        }

                         print("Contact List: \(self.allContacts)")
                        
                        self.checkData()
                    }
                }
            }
            
            
            
        }
    }
    
    
    func checkData() -> Void {
        
        for model in allContacts {
            if !self.uniqueContactsArray.contains(where: { $0.id == model.id }) {
                uniqueContactsArray.append(model)
            }
        }
        
        if self.uniqueContactsArray.count == 0 {
            
            self.noRecordLbl.isHidden = false
            self.chatListTV.isHidden = true
        }else {
            
            self.noRecordLbl.isHidden = true
            self.chatListTV.isHidden = false
        }
        
        self.chatListTV.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ChatsListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.uniqueContactsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChatTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "chat") as? ChatTableViewCell
        
        let m = uniqueContactsArray[indexPath.row]
        let name = m.name ?? ""
        if let firstCharacter = name.first {
            let firstLetter = String(firstCharacter)
            cell.nameBtn.setTitle(firstLetter.capitalized, for: .normal)
        } else {
            print("The string is empty.")
        }
        
        
        cell.nameLBL.text = name
        cell.msgLbl.text = ""
        cell.transform = CGAffineTransform(translationX: -cell.bounds.width, y: 0)

        UIView.animate(withDuration: 0.3, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
            cell.transform = CGAffineTransform.identity
            cell.alpha = 1.0
        }, completion: nil)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        performSegue(withIdentifier: "ChatSegue", sender: indexPath)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ChatSegue" {
//            if let indexPath = sender as? IndexPath {
//                let chat = uniqueContactsArray[indexPath.row]
//                if let destinationVC = segue.destination as? ChatViewController {
//                    destinationVC.user_ID = chat.id ?? ""
//                    destinationVC.user_name = chat.name ?? ""
//                }
//            }
//        }
//    }
//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chat = uniqueContactsArray[indexPath.row]
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        obj.user_ID = chat.id ?? ""
        obj.user_name = chat.name ?? ""
        
        self.navigationController!.pushViewController(obj, animated: true)
    }
}
