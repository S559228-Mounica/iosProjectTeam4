
//
//  LoginViewController.swift
//  BearcatsAccommodations
//
//  Created by  Bhargav Krishna Moparthy on 10/30/2023

import UIKit
import Toast
import FirebaseAuth
import Lottie

class LoginViewController: UIViewController {

   
    @IBOutlet weak var ErrLBL: UILabel!
    
    @IBOutlet weak var loginBTN: UIButton!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passTF: UITextField!
    
    var alert: UIAlertController?
    
    @IBOutlet var animationView: LottieAnimationView!
    
    var user_ID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       

        loginBTN.alpha = 0.0
        // Do any additional setup after loading the view.
       // animationView.loopMode = .loop
        animationView.play()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: emailTF)
               NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: passTF)
    }
    @objc func textFieldDidChange(_ notification: Notification) {
         
           let isNotEmpty = !(emailTF.text?.isEmpty ?? true) && !(passTF.text?.isEmpty ?? true)

              UIView.animate(withDuration: 0.5,
                             delay: 0,
                             usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5,
                             options: .curveEaseInOut,
                             animations: {
                                 self.loginBTN.alpha = isNotEmpty ? 1.0 : 0.0
                                 self.loginBTN.transform = isNotEmpty ? .identity : CGAffineTransform(scaleX: 0.1, y: 0.1)
                             },
                             completion: nil)
       }

    @IBAction func EmailText(_ sender: Any) {
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true

    }
    

    @IBAction func login(_ sender: Any) {
//                    if emailTF.text == "" {
//                        self.view.makeToast("Please enter email")
//                    } else if passTF.text == "" {
//                        self.view.makeToast("Please enter password")
//                    } else {
//                        self.showLoader()
//                        Auth.auth().signIn(withEmail: emailTF.text!, password: passTF.text!) { [weak self] authResult, error in
//                            guard let strongSelf = self else { return }
//        
//                            if error != nil {
//                                self?.alert?.dismiss(animated: false, completion: nil)
//                                self?.showErrorAlert(error: error?.localizedDescription ?? "")
//                                return
//                            }
//        
//                            self?.alert?.dismiss(animated: false, completion: nil)
//                            self?.performSegue(withIdentifier: "showHousesListSegue", sender: self)
//                        }
//                    }
//                }
        
        
        
        if emailTF.text == "" {
            
            self.view.makeToast("Please enter email")
        }else if passTF.text == "" {
            
            self.view.makeToast("Please enter password")
        }else {
            
            self.showLoader()
            Auth.auth().signIn(withEmail: emailTF.text!, password: passTF.text!) { [weak self] authResult, error in
                guard let strongSelf = self else { return }

                if let error = error {
                    self?.hideLoader()
                    print("Login failed")
                    
                    self?.animateLoginFailure()
                   
                    return
                }

                self?.alert?.dismiss(animated: false, completion: nil)
                let obj = self?.storyboard?.instantiateViewController(withIdentifier: "HousesListViewController") as! HousesListViewController
                self?.navigationController!.pushViewController(obj, animated: true)
            }
//            Auth.auth().signIn(withEmail: emailTF.text!,
//                               password: passTF.text!) { [weak self] authResult, error in
//                guard let strongSelf = self else { return }
//                
//                
//                if error != nil {
//                    
//                    self?.alert?.dismiss(animated: false, completion: nil)
//                    self?.showErrorAlert(error: error?.localizedDescription ?? "")
//                    return
//                }
//                
//                self?.alert?.dismiss(animated: false, completion: nil)
//              //  self?.performSegue(withIdentifier: "showHousesListSegue", sender: self)
//                
//                let obj = self?.storyboard?.instantiateViewController(withIdentifier: "HousesListViewController") as! HousesListViewController
//                self?.navigationController!.pushViewController(obj, animated: true)
//            }
        }
    }
    
    func animateLoginFailure() {
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: loginBTN.center.x - 5, y: loginBTN.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: loginBTN.center.x + 5, y: loginBTN.center.y))

        loginBTN.layer.add(shakeAnimation, forKey: "position")
    }

    @IBAction func signup(_ sender: Any) {
        
//        self.performSegue(withIdentifier: "signup", sender: self)
//    }
////            performSegue(withIdentifier: "signupSegue", sender: self)
////        }
////
////        // Add this method if you need to prepare data before transitioning to the SignupViewController
////        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////            if segue.identifier == "signupSegue" {
////                // You can prepare data for SignupViewController if needed
////            }
////        }

        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController!.pushViewController(obj, animated: true)
    }
    
    func showErrorAlert(error: String) -> Void {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func hideLoader() {
        alert?.dismiss(animated: true, completion: nil)
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
}

