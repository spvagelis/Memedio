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
    @IBOutlet weak var fontBarButton: UIBarButtonItem!
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    
    var selectedMemeItemNumber = Constants.initialSelectedMemeItemNumber
    var selectedFont = UIFont(name: Constants.fontOfTextField, size: Constants.defaultSizeOfTextFields)
    var startingXTopTextFieldConstant: CGFloat = 0.0
    var startingYTopTextFieldConstant: CGFloat = 0.0
    var startingXBottomTextFieldConstant: CGFloat = 0.0
    var startingYBottomTextFieldConstant: CGFloat = 0.0
    var centerXTopTextFieldConstraint: NSLayoutConstraint!
    var centerXBottomTextFieldConstraint: NSLayoutConstraint!
    var centerYTopTextFieldConstraint: NSLayoutConstraint!
    var centerYBottomTextFieldConstraint: NSLayoutConstraint!

    let fontPicker = UIFontPickerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setTextFieldAttributes()
        fontPicker.delegate = self
        
        view.backgroundColor = UIColor.black
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
    }
    
    func addTextFields() {

        view.addSubview(topTextField)
        view.addSubview(bottomTextField)

        topTextField.translatesAutoresizingMaskIntoConstraints = false
        bottomTextField.translatesAutoresizingMaskIntoConstraints = false

        self.centerYTopTextFieldConstraint = topTextField.centerYAnchor.constraint(equalTo: topToolBar.bottomAnchor, constant: 45)
        self.centerXTopTextFieldConstraint = topTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        topTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        topTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        self.centerYTopTextFieldConstraint.isActive = true
        self.centerXTopTextFieldConstraint.isActive = true

        self.centerYBottomTextFieldConstraint = bottomTextField.centerYAnchor.constraint(equalTo: bottomToolBar.topAnchor, constant: -45)
        self.centerXBottomTextFieldConstraint = bottomTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        bottomTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        bottomTextField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        self.centerYBottomTextFieldConstraint.isActive = true
        self.centerXBottomTextFieldConstraint.isActive = true

    }
    
    func setTextFieldAttributes() {
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Constants.fontOfTextField, size: Constants.defaultSizeOfTextFields)!,
            NSAttributedString.Key.strokeWidth: -4.0
        ]
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.text = Constants.topTextFieldText
        bottomTextField.text = Constants.bottomTextFieldText
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
        
        self.addTextFields()
        addPanGestureTopTextField(textField: topTextField)
        addPanGestureBottomTextFiled(textField: bottomTextField)
        addPinchGesture(textField: topTextField)
        addPinchGesture(textField: bottomTextField)
        addRotationGesture(textField: topTextField)
        addRotationGesture(textField: bottomTextField)
        
        if selectedMemeItemNumber != -1 {
            selectedFont = memes[selectedMemeItemNumber].memeFont
            imageView.image = memes[selectedMemeItemNumber].originalImage
            topTextField.text = memes[selectedMemeItemNumber].topText
            bottomTextField.text = memes[selectedMemeItemNumber].bottomText
            topTextField.font = UIFont(name: selectedFont!.fontName, size: Constants.defaultSizeOfTextFields)
            bottomTextField.font = UIFont(name: selectedFont!.fontName, size: Constants.defaultSizeOfTextFields)
            
            shareBarButton.isEnabled = true
        }
        
        cameraBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        subscribeToKeyboardNotifications()
        
        topTextField.isUserInteractionEnabled = true
        bottomTextField.isUserInteractionEnabled = true

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    
    @IBAction func fontButtonPressed(_ sender: UIBarButtonItem) {
        
        present(fontPicker, animated: true, completion: nil)
        
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
        dismiss(animated: true, completion: nil)
        
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
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage, memeFont: selectedFont!)
        
        // Add it to the memes array in the Application Delegate
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        
        if selectedMemeItemNumber == -1 {
            appDelegate.memes.append(meme)
        } else {
            appDelegate.memes.remove(at: selectedMemeItemNumber)
            appDelegate.memes.insert(meme, at: selectedMemeItemNumber)
            self.performSegue(withIdentifier: "toRoot", sender: self)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func createAnImagePicker(fromSource source: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.modalPresentationStyle = .popover
        
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
        
        if let image = info[.editedImage] as? UIImage {
            
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

        if textField.text == Constants.topTextFieldText || textField.text == Constants.bottomTextFieldText {

            textField.text = ""

        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
        
    }
}

extension MemeViewController: UIFontPickerViewControllerDelegate {
    
    func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
        
        guard let descriptor = viewController.selectedFontDescriptor else { return }
        
        let font = UIFont(descriptor: descriptor, size: Constants.defaultSizeOfTextFields)
        selectedFont = font
        topTextField.font = font
        bottomTextField.font = font
        
    }
}

extension MemeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
         
    }
    
    func addPinchGesture(textField: UITextField) {
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(MemeViewController.handlePinch(sender:)))
        
        
        pinchGesture.delegate = self
        textField.addGestureRecognizer(pinchGesture)
        
    }
    
    func addPanGestureTopTextField(textField: UITextField) {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MemeViewController.handlePanTopTextField(sender:)))
        textField.addGestureRecognizer(panGesture)
        
    }
    
    func addPanGestureBottomTextFiled(textField: UITextField) {

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(MemeViewController.handlePanBottomTextField(sender:)))
        textField.addGestureRecognizer(panGesture)

    }
    
    func addRotationGesture(textField: UITextField) {
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(MemeViewController.handleRotation(sender:)))
        rotateGesture.delegate = self
        textField.addGestureRecognizer(rotateGesture)
        
    }
    
    @objc func handlePanBottomTextField(sender: UIPanGestureRecognizer) {

        switch sender.state {
        case .began:
            self.startingYBottomTextFieldConstant = self.centerYBottomTextFieldConstraint.constant
            self.startingXBottomTextFieldConstant = self.centerXBottomTextFieldConstraint.constant

        case .changed:
            let translation = sender.translation(in: self.view)
            self.centerYBottomTextFieldConstraint.constant = self.startingYBottomTextFieldConstant + translation.y
            self.centerXBottomTextFieldConstraint.constant = self.startingXBottomTextFieldConstant + translation.x
        default:
            break
        }

    }
    
    @objc func handlePanTopTextField(sender: UIPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            self.startingYTopTextFieldConstant = self.centerYTopTextFieldConstraint.constant
            self.startingXTopTextFieldConstant = self.centerXTopTextFieldConstraint.constant
            
        case .changed:
            let translation = sender.translation(in: self.view)
            self.centerYTopTextFieldConstraint.constant = self.startingYTopTextFieldConstant + translation.y
            self.centerXTopTextFieldConstraint.constant = self.startingXTopTextFieldConstant + translation.x
        default:
            break
        }
    }
    
    @objc func handleRotation(sender: UIRotationGestureRecognizer) {
        
        sender.view?.transform = (sender.view?.transform)!.rotated(by: sender.rotation)
        sender.rotation = 0
        
    }
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
        
        
        sender.view?.transform = (sender.view?.transform)!.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
        
    }
}

