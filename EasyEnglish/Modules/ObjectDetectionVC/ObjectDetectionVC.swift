//
//  ObjectDetectionVC.swift
//  EasyEnglish
//
//  Created by Ihor Mostoviy on 11.05.2020.
//  Copyright © 2020 Мостовий Ігор. All rights reserved.
//

import UIKit
import AVKit
import Vision
import CoreMedia
import CoreData

final class ObjectDetectionVC: UIViewController {
    // MARK: - State
    private var captureSesion: AVCaptureSession!
    private var searchingWord: String?

    // MARK: - @IBOutlets
    @IBOutlet private weak var cameraLayerView: UIView!
    @IBOutlet private weak var objectLabel: UILabel!
    @IBOutlet private weak var findInDictionatyButton: UIButton!
    @IBOutlet private weak var noWordButton: UIButton!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configurateCaptureSession()
    }

    private func configurateCaptureSession() {
        captureSesion = AVCaptureSession()
        captureSesion.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

        captureSesion.addInput(input)

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSesion)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        cameraLayerView.layer.addSublayer(previewLayer)

        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSesion.startRunning()
            DispatchQueue.main.async {
                previewLayer.frame = self.cameraLayerView.bounds
            }
        }

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ObjectDetection"))
        captureSesion.addOutput(dataOutput)
    }

    deinit {
        captureSesion.stopRunning()
    }

    private func reseiveObjects(results: [Any]?) {
        guard let object = (results as? [VNClassificationObservation])?.first else { return }

        DispatchQueue.main.async { [weak self] in
            self?.findInDictionatyButton.isHidden = false
            self?.objectLabel.isHidden = false
            self?.objectLabel.text = object.identifier
        }
    }

    // MARK: - @IBActions
    @IBAction private func backButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findInDictionaryTouched(_ sender: Any) {
        guard let object = objectLabel.text?.lowercased(),
            let objectName = object.components(separatedBy: ", ").first else { return }
        searchingWord = String(objectName)
        findInDictionatyButton.setTitle("Find in dictionary: \(objectName)", for: .normal)
        let context = CoreDataStack.shared.persistantContainer.viewContext
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "word contains[c] %@", String(objectName))

        guard let result = try? context.fetch(request).first else {
            noWordButton.setTitle("No \(objectName) in dictionary. Tap to add", for: .normal)
            noWordButton.isHidden = false
            return
        }

        guard let controller = UIStoryboard(name: "ShowDetail", bundle: nil)
            .instantiateViewController(withIdentifier: WordDetailsVC.identifier) as? WordDetailsVC else { return }
        controller.context = result
        present(controller, animated: true)
    }

    @IBAction func noWordButtonTouched(_ sender: Any) {
        noWordButton.isHidden = true
        guard let controller = UIStoryboard(name: "AddNewWord", bundle: nil)
            .instantiateViewController(withIdentifier: AddEditWordVC.reuseIdentifier) as? AddEditWordVC else { return }
        controller.newWord = searchingWord
        present(controller, animated: true)
    }
}

extension ObjectDetectionVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let model = try? VNCoreMLModel(for: Resnet50().model) else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            self?.reseiveObjects(results: request.results)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
