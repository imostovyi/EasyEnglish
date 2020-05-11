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

    // MARK: - @IBOutlets
    @IBOutlet private var cameraLayerView: UIView!
    @IBOutlet private var objectLabel: UILabel!
    @IBOutlet private var findInDictionatyButton: UIButton!

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
            let objectName = object.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true).first else { return }
        let context = CoreDataStack.shared.persistantContainer.viewContext
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.predicate = NSPredicate(format: "word contains[c] %@", String(objectName))

        let result = try? context.fetch(request)
        print(result)
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
