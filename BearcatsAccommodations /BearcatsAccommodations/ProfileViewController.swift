//
//  ProfileViewController.swift
//  BearcatsAccommodations
//
//  Created by Bhargav Krishna Moparthy on 11/18/23.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    
    @IBOutlet var nameLbl: UILabel!
    
    @IBOutlet var emailLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Profile"
        
        nameLbl.text = Auth.auth().currentUser?.displayName ?? ""
        emailLbl.text = Auth.auth().currentUser?.email ?? ""
        
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

}
