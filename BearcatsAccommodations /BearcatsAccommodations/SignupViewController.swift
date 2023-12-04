//
//  SignupViewController.swift
//  BearcatsAccommodations
//
//  Created by Mounica Seelam on 11/05/2023.
//

import UIKit
import Toast
import FirebaseAuth
import Lottie
class SignupViewController: UIViewController {

    
    
    @IBOutlet weak var regBTN: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var passTF: UITextField!
    
    @IBOutlet weak var confirmPassTF: UITextField!
    @IBOutlet var animationView: LottieAnimationView!
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isHidden = false
        
      //  animationView.loopMode = .loop
        animationView.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func register(_ sender: Any) {
        
        if nameTF.text == "" {
            
            self.view.makeToast("enter name")
            self.animateFailure()
            return
        }
        
        if emailTF.text == "" {
            self.animateFailure()
            self.view.makeToast("enter email")
            return
        }
        
        if passTF.text == "" {
            self.animateFailure()
            self.view.makeToast("enter password")
            return
        }
        
        if confirmPassTF.text == "" {
            self.animateFailure()
            self.view.makeToast("enter confirm password")
            return
        }
        
        if passTF.text != confirmPassTF.text {
            self.animateFailure()
            self.view.makeToast("Password not matched.")
            return
        }
        
        
        self.showLoader()
        Auth.auth().createUser(withEmail: emailTF.text!,
                               password: passTF.text!) { authResult, error in
          
            if error != nil {
                
                self.alert?.dismiss(animated: true)
                self.showErrorAlert(error: error?.localizedDescription ?? "")
            }else{
                
                let profile = authResult?.user.createProfileChangeRequest()
                profile?.displayName = self.nameTF.text!
                profile?.commitChanges(completion: { error in
                    if error != nil {
                        
                        self.alert?.dismiss(animated: true)
                        self.showErrorAlert(error: error?.localizedDescription ?? "")
                    }else{
                        
                        self.alert?.dismiss(animated: true)
                    //    self.performSegue(withIdentifier: "showHouseslistSegue", sender: self)

                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HousesListViewController") as! HousesListViewController
                        self.navigationController!.pushViewController(obj, animated: true)
                    }
                })
            }
        }
    }
    
    
    func moveToHome() -> Void {
        
        
    }
    func animateFailure() {
        let shakeAnimation = CABasicAnimation(keyPath: "position")
        shakeAnimation.duration = 0.1
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        shakeAnimation.fromValue = NSValue(cgPoint: CGPoint(x: regBTN.center.x - 5, y: regBTN.center.y))
        shakeAnimation.toValue = NSValue(cgPoint: CGPoint(x: regBTN.center.x + 5, y: regBTN.center.y))

        regBTN.layer.add(shakeAnimation, forKey: "position")
    }
    @IBAction func login(_ sender: Any) {
        
    
        
        self.navigationController?.popViewController(animated: true)
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
