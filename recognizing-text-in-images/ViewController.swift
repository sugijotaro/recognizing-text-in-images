//
//  ViewController.swift
//  recognizing-text-in-images
//
//  Created by JotaroSugiyama on 2023/02/19.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recognizedTextView: UITextView!
    
    private var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:))))
    }
    
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        recognizeText(image: image)
    }
    
    private func recognizeText(image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let recognizeTextRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        recognizeTextRequest.recognitionLevel = .accurate
        recognizeTextRequest.recognitionLanguages = ["en_US"]
        recognizeTextRequest.usesLanguageCorrection = true
        do {
            try requestHandler.perform([recognizeTextRequest])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        recognizedText = ""
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            recognizedText += topCandidate.string + " "
        }
        DispatchQueue.main.async {
            self.recognizedTextView.text = self.recognizedText
        }
    }
}
