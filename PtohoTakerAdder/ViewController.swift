//
//  ViewController.swift
//  PtohoTakerAdder
//
//  Created by Pavlo Novak on 4/19/18.
//  Copyright © 2018 Pavlo Novak. All rights reserved.
//

import UIKit
import Photos
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var array: [String]? = nil
    
    var transaction: [NSManagedObject] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        let assets = PHAsset.fetchAssets(with: options)
        // MARK:- Just check
        let firstAsset = assets[1]
        PHImageManager.default().requestImage(for: firstAsset, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill, options: nil) { (image, _) in
            self.imageView.image = image
        }
    }
    
    func save(name: String) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        // Taking managedContext
        let managedContext = appDelegate.persistentContainer.viewContext
        // Creating new managed Object
        let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: managedContext)!
        let image = NSManagedObject(entity: entity, insertInto: managedContext)
        // Setting new value to managedObject via KVC
        image.setValue(name, forKeyPath: "image")
        // Commit changes in the managedContext
        do {
            try managedContext.save()
            transaction.append(image)
        } catch let error as NSError {
            print("Couldn't save. \(error), \(error.userInfo)")
        }
        print(transaction.count)
    }
    
    // Did finish picking
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //let chosenAsset = info[UIImagePickerControllerPHAsset]!
        let image = info[UIImagePickerControllerPHAsset]
        
        DispatchQueue.main.async {
            self.save(name: (image as! PHAsset).localIdentifier)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Did cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source for photo", preferredStyle: .actionSheet)
        

        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: UIButton) {
        
        // создаем объект по индекспату(тут 0)
        // вынимаем ассет по нужному айди, засовываем имеж во вью
        let tran = transaction[0]
        let transact = tran.value(forKeyPath: "image") as! String
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [transact], options: nil)
        
        PHImageManager.default().requestImage(
            for: asset[0],
            targetSize: imageView.frame.size,
            contentMode: .aspectFill,
            options: nil) { (image, _) -> Void in
                self.imageView.image = image
        }
        //view.layoutIfNeeded()
        //view.setNeedsLayout()
        view.setNeedsDisplay()
    }
}

