//
//  SettingsTableViewController.swift
//  Catenaccio
//
//  Created by Richard Kolen on 24-06-17.
//  Copyright © 2017 kolex. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate {
    func updateProfileInformation()
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var ActivityIndicatorView: UIActivityIndicatorView!
    
    var delegate: SettingsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Profile Settings"
        usernameTextField.delegate = self
        emailTextField.delegate = self
        fetchCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCurrentUser() {
        Api.User.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            
            if let profileUrl = URL(string: user.profileImageUrl!) {
                self.profileImage.sd_setImage(with: profileUrl)
            }
        }
    }
    
    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
        if let profileImg = self.profileImage.image, let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            ActivityIndicatorView.startAnimating()
            AuthService.updateUserInformation(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSucces: {
                self.ActivityIndicatorView.stopAnimating()
                ProgressHUD.showSuccess("Goal!")
                self.delegate?.updateProfileInformation()
            }, onError: { (errorMessage) in
                self.ActivityIndicatorView.stopAnimating()
                ProgressHUD.showError(errorMessage)
            })
        }
    }

    @IBAction func logOutButtonTouchUpInside(_ sender: Any) {
        AuthService.logOut(onSucces: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
            self.present(signInVC, animated: true, completion: nil)
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func changeProfileImageTouchUpInside(_ sender: Any) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

extension SettingsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            profileImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}





