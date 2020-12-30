//
//  MemeViewController.swift
//  Memedio
//
//  Created by vagelis spirou on 21/12/20.
//

import UIKit

class MemeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        topTextField.delegate = self
        bottomTextField.delegate = self
        setTextFieldAttributes()
        
    }
    
    func setTextFieldAttributes() {
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -4.0
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        topTextField.textAlignment = .center
        topTextField.borderStyle = .none
        topTextField.autocapitalizationType = .allCharacters
        topTextField.adjustsFontSizeToFitWidth = true
        topTextField.minimumFontSize = 7.0
        bottomTextField.textAlignment = .center
        bottomTextField.borderStyle = .none
        bottomTextField.autocapitalizationType = .allCharacters
        bottomTextField.adjustsFontSizeToFitWidth = true
        bottomTextField.minimumFontSize = 7.0
        
        imageView.image = UIImage()
        shareBarButton.isEnabled = false
        
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        
        let memeImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memeImage], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, arrayReturnedItems: [Any]?, error: Error?) in
            
            if error == nil {
                if completed {
                    self.save()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        setTextFieldAttributes()
        
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        
        return keyboardSize.cgRectValue.height
        
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if bottomTextField.isFirstResponder {
            
            view.frame.origin.y = -getKeyboardHeight(notification)
            
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if bottomTextField.isFirstResponder {
            
            view.frame.origin.y = 0
            
        }
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        
        topToolBar.isHidden = true
        bottomToolBar.isHidden = true
        
        // Render view to an image
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        
        topToolBar.isHidden = false
        bottomToolBar.isHidden = false
        
        return memedImage
        
    }
    
    func save() {
        
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
        
    }
    
    func createAnImagePicker(fromSource source: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        
        present(imagePicker, animated: true, completion: nil)
        
    }

    @IBAction func pickAnImageFromPhotoLibrary(_ sender: Any) {
        
        createAnImagePicker(fromSource: .photoLibrary)
        
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        createAnImagePicker(fromSource: .camera)
        
    }
}

extension MemeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            
            dismiss(animated: true, completion: nil)
            
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            shareBarButton.isEnabled = true
            
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
    }
}

extension MemeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        textField.text = ""
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}

