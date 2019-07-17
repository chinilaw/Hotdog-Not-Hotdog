//
//  ViewController.swift
//  Seafood
//
//  Created by Jules Lee on 17/07/2019.
//  Copyright © 2019 Jules Lee. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickerImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickerImage
            
            // to allow coreml and vision to use this image
            guard let ciimage = CIImage(image: userPickerImage) else {
                fatalError("Cannot convert to CIImage")
            }
            detect(image: ciimage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
        
        // Next -> in info.plist add property
        // Privacy Camera Usage Descriptiion -> We need to use the camera
        // Privacy Photo Library Usage -> We need your photos
        
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        // ask model to classify
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to present image")
            }
            
            if let firstResult = results.first {
                self.navigationItem.title = firstResult.identifier.contains("hotdog") ? "Hotdog!" : "Not Hotdog!"
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTagged(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

