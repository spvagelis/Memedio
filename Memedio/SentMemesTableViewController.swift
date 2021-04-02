//
//  SentMemesTableViewController.swift
//  Memedio
//
//  Created by vagelis spirou on 11/1/21.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    var selectedRow = 0
    
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Sent Memes"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundColor = UIColor.black
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }

    // MARK: - TableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "memeTableCell") as? MemeTableViewCell else { return UITableViewCell() }
        
        let selectedMeme = memes[indexPath.row]
    
        cell.memeImageView.image = selectedMeme.memedImage
        cell.titleLabel.text = "\(selectedMeme.topText)" + "..." + "\(selectedMeme.bottomText)"
        cell.titleLabel.font = UIFont(name: selectedMeme.memeFont.fontName, size: 20)
        cell.titleLabel.textColor = UIColor.white
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.black
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            let object = UIApplication.shared.delegate
            let appDelegate = object as! AppDelegate
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        selectedRow = indexPath.row
        performSegue(withIdentifier: "toDetailVC", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            
            let destinationVC = segue.destination as! DetailViewController
            let selectedMeme = memes[selectedRow]
            destinationVC.selectedMemeItemNumber = selectedRow
            destinationVC.memeFromPreviousView = selectedMeme
            
        }
    }
}


