/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToList = "LoginToList"
    let listToUsers = "signupToList"
    
    //let ref = Database.database().reference(withPath: "grocery-items")
    @IBOutlet weak var Info: UILabel!
    @IBOutlet weak var LoginButton: UIButton!
    
    @IBOutlet weak var SignUpButton: UIButton!
    // MARK: Outlets
    //@IBOutlet weak var textFieldLoginEmail: UITextField!
    //@IBOutlet weak var textFieldLoginPassword: UITextField!
    
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //???
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UIView.animate(withDuration: 0.9, delay: 0.0, options: [.curveEaseInOut],
                       animations: {
                    self.textFieldLoginEmail.center.x += self.view.bounds.width
                    self.textFieldLoginPassword.center.x += self.view.bounds.width
                    
                        self.LoginButton.center.x -= self.view.bounds.width
                        self.SignUpButton.center.x -= self.view.bounds.width
        },
                       completion: nil
        )
        
        UIView.animate(withDuration: 0.9, delay: 0.2, options: [.curveEaseInOut],
                       animations: {
                        self.Info.center.y += self.view.bounds.height
        },
                       completion: nil
        )
        //Behavior for user already logged in. (Remember me)
        // 1
        Auth.auth().addStateDidChangeListener() { auth, user in
            // 2
            if user != nil {
                // 3
                //self.performSegue(withIdentifier: self.loginToList, sender: nil)
                //self.textFieldLoginEmail.text = nil
                //self.textFieldLoginPassword.text = nil
            }
            
            
        }
        
        //        //Get user's grocery's list
        //        Auth.auth().addStateDidChangeListener { auth, user in
        //            guard let user = user else { return }
        //            self.user = User(authData: user)
        //        }
    }
    
    
//    @IBAction func loginDidTouch(_ sender: Any) {
//    }
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        guard //catch scenario where nothing is entered.
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if error != nil {
                self.performSegue(withIdentifier: "loginToHome", sender: self)
            }
            
            if let error = error, user == nil { //Invalid account response
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            
        }
    }
    
//    @IBAction func signUpDidTouch(_ sender: Any) {
//    }
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        print("sign up")
        let alert = UIAlertController(title: "Register",
                                      message: "Register",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // 1
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            // 2
            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
                if error == nil {
                    // 3
                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                                       password: self.textFieldLoginPassword.text!)
                    
                    self.performSegue(withIdentifier: self.listToUsers, sender: nil)
                }
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField { textEmail in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextField { textPassword in
            textPassword.isSecureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 1
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: [.curveEaseInOut], animations: { () -> Void in
                view.alpha = 0
            },
                                       completion: nil)
        }
    }
    
    func fadeViewOutThenIn(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 0.25
        
        // Fade in the view
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            view.alpha = 0
        }) { (Bool) -> Void in
            
            // After the animation completes, fade out the view after a delay
            
            UIView.animate(withDuration: animationDuration, delay: delay, options: .curveEaseInOut, animations: { () -> Void in
                view.alpha = 1
            },
                                       completion: nil)
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
