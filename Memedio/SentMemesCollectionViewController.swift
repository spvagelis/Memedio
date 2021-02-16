//
//  SentMemesCollectionViewController.swift
//  Memedio
//
//  Created by vagelis spirou on 11/1/21.
//

import UIKit



class SentMemesCollectionViewController: UICollectionViewController {
    
    let space: CGFloat = 3.0
    var selectedItem = 0
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
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
        
        collectionView.backgroundColor = UIColor.black
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .always
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
    
    }
    
    func setCollectionViewItemSize(size: CGSize) -> CGSize {

        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {

            let width = (size.width - 1 * space) / 8
            return CGSize(width: width, height: width)

        } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {

            let width = (size.width - 1 * space) / 8
            return CGSize(width: width, height: width)
        } else {

            let width = (size.width - 2 * space) / 3
            return CGSize(width: width, height: width)
            
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
        
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return memes.count
        
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCell", for: indexPath) as? MemeCollectionViewCell else { return UICollectionViewCell() }
        
        let selectedMeme = memes[indexPath.row]
        
        cell.imageView.image = selectedMeme.memedImage
        cell.backgroundColor = UIColor.black
        
        return cell
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        flowLayout?.invalidateLayout()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedItem = indexPath.item
        performSegue(withIdentifier: "toDetailVC", sender: memes[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDetailVC" {
            
            let destinationVC = segue.destination as! DetailViewController
            let selectedMeme = memes[selectedItem]
            destinationVC.selectedMemeItemNumber = selectedItem
            destinationVC.memeFromPreviousView = selectedMeme
            
        }
    }
}
//MARK: - UICollectionViewDelegateFlowLayout

extension SentMemesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        return setCollectionViewItemSize(size: size)

    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return space

    }
}
