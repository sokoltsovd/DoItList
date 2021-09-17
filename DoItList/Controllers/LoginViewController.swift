//
//  ViewController.swift
//  DoItList
//
//  Created by Dmitry Sokoltsov on 06.09.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    let segueIdentifier = "tasksSegue"
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var passLabel: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://doitlist-d7339-default-rtdb.europe-west1.firebasedatabase.app").reference(withPath: "users")
        
//        Добавляем наблюдателя для клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        warnLabel.alpha = 0
        
        Auth.auth().addStateDidChangeListener ({ [weak self] (auth, user) in
            if user != nil {
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailLabel.text = ""
        passLabel.text = ""
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + kbFrameSize.height)
        
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }
    
    @objc func kbDidHide(notification: Notification) {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    func displayWarning(withText text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            [weak self] in self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    @IBAction func LoginButton(_ sender: UIButton) {
        guard let email = emailLabel.text, let password = passLabel.text, email != "", password != "" else {
            displayWarning(withText: "Info is non correct")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] (user, error) in
            if error != nil {
                self?.displayWarning(withText: "Error occured")
                return
            }
            
            if user != nil {
                self?.performSegue(withIdentifier: "tasksSegue", sender: nil)
                return
            }
            
            self?.displayWarning(withText: "No such user")
        })
    }
    
    @IBAction func registerButton(_ sender: UIButton) {
        guard let email = emailLabel.text, let password = passLabel.text, email != "", password != "" else {
            displayWarning(withText: "Info is non correct")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] (user, error) in
            
            guard error == nil, user != nil else {
                
                print(error!.localizedDescription)
                return
            }
            
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
            
        })
        
    }
    
}

