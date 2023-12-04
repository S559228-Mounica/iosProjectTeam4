//
//  InitialViewController.swift
//  BearcatsAccommodations
//
//  Created by  Bhargav Krishna Moparthy on 10/30/2023

import UIKit
import FirebaseAuth
import Lottie

class InitialViewController: UIViewController {
    @IBOutlet var animationView: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        perform(#selector(moveToView), with: nil, afterDelay: 6.0)
        
       // animationView.loopMode = .loop
        animationView.play()
    }
    
    @objc func moveToView() {
     
          //  self.performSegue(withIdentifier: "id1", sender: self)
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.navigationController!.pushViewController(obj, animated: true)
            
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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
