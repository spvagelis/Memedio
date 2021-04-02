//
//  DetailViewController.swift
//  Memedio
//
//  Created by vagelis spirou on 18/1/21.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    var selectedMemeItemNumber: Int?
    var memeFromPreviousView: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        guard let memeFromPreviousView = memeFromPreviousView else { return }
        imageView.image = memeFromPreviousView.memedImage

    }
    
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "toMemeVC", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toMemeVC" {
            
            let destinationVC = segue.destination as! MemeViewController
            
            guard let selectedMemeItemNumber = selectedMemeItemNumber else { return }
                
            destinationVC.selectedMemeItemNumber = selectedMemeItemNumber
                
        }
    }
}
