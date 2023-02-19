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
    
    @IBOutlet weak var languageButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recognizedTextView: UITextView!
    
    private var currentRecognitionLanguage: String = "en_US"
    private var recognizedText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let languageMenu = UIMenu(title: "", children: [
            UIAction(title: "English", image: nil, identifier: nil, handler: { _ in
                self.currentRecognitionLanguage = "en_US"
                self.languageButton.title = "English"
                self.recognizeText(image: self.imageView.image ?? UIImage())
            }),
            UIAction(title: "日本語", image: nil, identifier: nil, handler: { _ in
                self.currentRecognitionLanguage = "ja_JP"
                self.languageButton.title = "日本語"
                self.recognizeText(image: self.imageView.image ?? UIImage())
            })
        ])
        languageButton.menu = languageMenu
    }
    
    @IBAction func imageSelectButtonTapped(_ sender: Any) {
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
        recognizeTextRequest.recognitionLanguages = [currentRecognitionLanguage]
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
