//
//  ProfileViewController.swift
//  PoseEstimation-CoreML
//
//  Created by Binh Tran on 2/25/19.
//  Copyright © 2019 tucan9389. All rights reserved.
//
import UIKit
import Foundation
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var profileBio: UITextView!
    @IBOutlet weak var activityTable: UITableView!
    let ref = Database.database().reference(withPath: "grocery-items")
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //fadeViewInThenOut(view: self.view, delay: 0.0)
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
        self.profilePicture.clipsToBounds = true;
        

        self.profilePicture.layer.borderWidth = 3.0
        self.profilePicture.layer.borderColor = UIColor.white.cgColor
        
        Auth.auth().addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        }
        
        //user = User(uid: "FakeId", email: "hungry@person.food")
//        profilePicture.frame = CGRect(x:100, y:100, width:profilePicture.frame.width , height:profilePicture.frame.height)
//        profilePicture.layer.borderColor  = UIColor.red.cgColor
//        profilePicture.layer.cornerRadius = 10
//        profilePicture.layer.masksToBounds = true
//        profilePicture.layer.borderWidth = 5
        
        // 1 watch data in db.
        //profileBio.delegate = self
        ref.observe(.value, with: { snapshot in
            // 2
            var newItems: [GroceryItem] = []
            
            // 3
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let groceryItem = GroceryItem(snapshot: snapshot) {
                    if groceryItem.addedByUser == self.user.email{
                        self.profileBio.text = groceryItem.name
                        return
                    }
                    //newItems.append(groceryItem)
                }
            }
            
            // 5 Set our values.
//            self.items = newItems
//            self.tableView.reloadData()
        })//Observables for db values
    }
    
    //For number countdown. Possibly add translation animation.
    func fadeViewInThenOut(view : UIView, delay: TimeInterval) {
        
        let animationDuration = 2.25
        
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
    
    
    @IBAction func EditProfile(_ sender: Any) {
        let alert = UIAlertController(title: "Edit Bio", //Maybe make grocery-itmes into bio json.
                                      message: "Add a description",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            // 1
            guard let textField = alert.textFields?.first,
                let text = textField.text else { return }
            
            // 2
            let groceryItem = GroceryItem(name: text,
                                          addedByUser: self.user.email,
                                          completed: false)
            // 3
            let groceryItemRef = self.ref.child(text.lowercased())
            
            // 4
            groceryItemRef.setValue(groceryItem.toAnyObject()) //this conversts to json to upload to db.
            
            self.ref.child(self.profileBio.text).removeValue { user, error in
//                if error != nil {
//                    print("error \(error)")
//                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
