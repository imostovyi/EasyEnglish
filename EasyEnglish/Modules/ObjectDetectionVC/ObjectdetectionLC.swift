//
//  ObjectdetectionLC.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 21.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//

import AVKit
import CoreData
import Vision

final class ObjectDetectionLC: NSObject {

    public var updatedProps: ((ObjectDetectionVC.Props) -> Void)? {
        didSet {
            start()
        }
    }
    
    private let model = try! VNCoreMLModel(for: Resnet50().model)
    
    private lazy var captureSession = AVCaptureSession()
    private var objectInCamera: String?
    private var shouldShowAddButton: Bool = false
    private var focusedObject: String = ""
    
    private let appCoordinator: AppCoordinator
    
    private let context = CoreDataStack.shared.persistantContainer.viewContext
    private let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
    
    // MARK: Life cycle
    
    init(coordinator: AppCoordinator) {
        self.appCoordinator = coordinator
        super.init()
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    private func start() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let captureDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }

        captureSession.addInput(input)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "ObjectDetection"))
        captureSession.addOutput(dataOutput)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    private func generateProps() {
        updatedProps?(
            .init(
                capturedObject: objectInCamera,
                focusedObject: focusedObject,
                session: captureSession,
                shouldShowAddButton: shouldShowAddButton,
                findInDictionary: { [weak self] in
                    self?.findInDictionary()
                }
            )
        )
    }
    
    private func receivedObjects(results: [Any]?) {
        guard let object = (results as? [VNClassificationObservation])?.first else { return }
        objectInCamera = object.identifier
        generateProps()
    }
    
    private func findInDictionary() {
        guard let objectName = objectInCamera else {
            return
        }
        
        focusedObject = objectName
        fetchRequest.predicate = NSPredicate(
            format: "word contains[c] %@", objectName.lowercased()
        )
        guard let word = try? context.fetch(fetchRequest).first else {
            shouldShowAddButton = true
            generateProps()
            return
        }
        appCoordinator.showWordDetailsScreen(word)
    }
}


extension ObjectDetectionLC: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            self?.receivedObjects(results: request.results)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
