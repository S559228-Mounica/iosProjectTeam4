//
//  ChatViewController.swift
//  BearcatsAccommodations
//
//  Created by Aashritha Dodda on 11/12/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import AVKit
import FittedSheets

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTV: UITableView!
    
    @IBOutlet var msgView: UIView!
    
    
    @IBOutlet weak var msgTF: UITextField!
    
    
    @IBOutlet weak var audioBtn: UIButton!
    @IBOutlet weak var textBtn: UIButton!
    
    
    var user_ID = ""
    var user_name = ""
    let db = Firestore.firestore()
    var allChat: [ChatModel] = []
    
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Chat"
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        // Do any additional setup after loading the view.
        
        self.chatTV.delegate = self
        self.chatTV.dataSource = self
        
        self.getAllChat()
    }
    

    func getAllChat() -> Void {
                
        let id = Auth.auth().currentUser?.uid ?? ""
        let docRef = db.collection("Chats")
            .whereField("sender_id", in: [id, user_ID])
            .whereField("receiver_id", in: [id, user_ID])
        
        //self.showLoader()
        docRef.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.alert?.dismiss(animated: true)
                
            } else {
                
                self.allChat.removeAll()
                
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    let data = document.data()
                    
                    let t = data["timestamp"] as? Double ?? 0.0
                    let date = Date(timeIntervalSince1970: t)
                    
                    var chat = Chat()
                    chat.id = document.documentID
                    chat.message = data["message"] as? String ?? ""
                    chat.type = data["type"] as? Int ?? 0
                    chat.sender_id = data["sender_id"] as? String ?? ""
                    chat.reveiver_id = data["reveiver_id"] as? String ?? ""
                    
                    let dur = data["duration"] as? String ?? "0"
                    chat.duration = Int(dur)
                    chat.url = data["url"] as? String ?? ""
                    
                    
                    let f = DateFormatter()
                    f.dateFormat = "HH:mm:ss"
                    
                    chat.date = f.string(from: date)
                    
                    f.dateFormat = "MM/dd/yyyy"
                    let date_str = f.string(from: date)
                    
                    if let existingSectionIndex = self.allChat.firstIndex(where: { $0.date == date_str }) {
                        self.allChat[existingSectionIndex].chats?.append(chat)
                    } else {
                        var newSection = ChatModel()
                        newSection.date = date_str
                        newSection.chats = [chat]
                        self.allChat.append(newSection)
                    }
                    
                    
                    self.alert?.dismiss(animated: true)
                    self.allChat.sort { $0.date! < $1.date! }
                    self.chatTV.reloadData()
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

    
    @IBAction func sendBtn(_ sender: Any) {
        
        if msgTF.text == "" {
            
            self.view.makeToast("Please enter message")
            return
        }
        
        self.showLoader()
        let myTimeStamp = Date().timeIntervalSince1970
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let params = ["message": msgTF.text!,
                      "url": "",
                      "sender_id": id,
                      "sender_name": name,
                      "receiver_id": user_ID,
                      "receiver_name": user_name,
                      "type": 1,
                      "timestamp": myTimeStamp] as [String : Any]
        
        
        let path = String(format: "Chats")
        let db = Firestore.firestore()
        
        db.collection(path).document().setData(params) { err in
            if let _ = err {
                
                self.alert?.dismiss(animated: true)
                self.view.makeToast("Message sending failed")
            } else {
                
                self.alert?.dismiss(animated: true)
                self.view.makeToast("Message sent successfully")
                self.msgTF.text = ""
                //self.getAllChat()
                
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
    
    //MARK: Audio Message
    @IBAction func audioBtn(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SendVoiceMessageVC") as! SendVoiceMessageVC
        
        //vc.delegate = self
        vc.user_ID = self.user_ID
        vc.user_name = self.user_name
        
        let sheetController = SheetViewController(
            controller: vc,
            sizes: [.fixed(160.0)])
        
        sheetController.allowPullingPastMaxHeight = false
        sheetController.allowPullingPastMinHeight = false
        sheetController.autoAdjustToKeyboard = false
        sheetController.cornerRadius = 16
        sheetController.dismissOnOverlayTap = false
        sheetController.dismissOnPull = false
        sheetController.contentBackgroundColor = .clear
        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.6)
        
        self.present(sheetController, animated: false) {}
    }
}


extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return allChat.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell = Bundle.main.loadNibNamed("HeaderTVC", owner: self, options: nil)?.first as! HeaderTVC
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let date_str = allChat[section].date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        let today = Date()
        let today_str = dateFormatter.string(from: today)
        
        let yesterday = today.addingTimeInterval(-1 * 24 * 60 * 60)
        let yesterday_str = dateFormatter.string(from: yesterday)
        
        if date_str == today_str {
            
            cell.dateBtn.setTitle("Today".uppercased(), for: .normal)
        }else if date_str == yesterday_str {
            
            cell.dateBtn.setTitle("Yesterday".uppercased(), for: .normal)
        }else {
            
            cell.dateBtn.setTitle(date_str, for: .normal)
        }
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let chats = allChat[section].chats ?? []
        return chats.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var chats = allChat[indexPath.section].chats ?? []
        chats.sort { $0.date! < $1.date! }
        let chat = chats[indexPath.row]
        
        let id = Auth.auth().currentUser?.uid ?? ""
        
        if chat.sender_id == id {
            let cell = Bundle.main.loadNibNamed("senderTableViewCell", owner: self)?.first as! senderTableViewCell
            
           
            cell.transform = CGAffineTransform(translationX: tableView.bounds.width, y: 0)
            
            
            UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            
            cell.chat = chat
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("receiverTableViewCell", owner: self)?.first as! receiverTableViewCell
            
            
            cell.transform = CGAffineTransform(translationX: -tableView.bounds.width, y: 0)
            
           
            UIView.animate(withDuration: 0.5, delay: 0.1 * Double(indexPath.row), options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            
            cell.chat = chat
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var chats = allChat[indexPath.section].chats ?? []
        chats.sort { $0.date! < $1.date! }
        let chat = chats[indexPath.row]
        
        let type = chat.type
        if type == 4 {
            
            let url = chat.url ?? ""
            let duration = chat.duration ?? 0
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ReadVoiceMessageVC") as! ReadVoiceMessageVC
            
            vc.audioURL = url
            vc.serverDuration = Int(duration)
            
            let sheetController = SheetViewController(
                controller: vc,
                sizes: [.fixed(160.0)])
            
            sheetController.allowPullingPastMaxHeight = false
            sheetController.allowPullingPastMinHeight = false
            sheetController.autoAdjustToKeyboard = false
            sheetController.cornerRadius = 16
            sheetController.dismissOnOverlayTap = false
            sheetController.dismissOnPull = false
            sheetController.contentBackgroundColor = .clear
            sheetController.overlayColor = UIColor.black.withAlphaComponent(0.6)
            
            self.present(sheetController, animated: false) {}
        }
    }
    

}
