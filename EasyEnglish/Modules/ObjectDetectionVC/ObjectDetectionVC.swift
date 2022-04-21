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
    private var props: Props?
    
    // MARK: Public
    public var logicController: ObjectDetectionLC!

    // MARK: - @IBOutlets
    @IBOutlet private weak var cameraLayerView: UIView!
    @IBOutlet private weak var objectLabel: UILabel!
    @IBOutlet private weak var findInDictionaryButton: UIButton!
    @IBOutlet private weak var addNewWordButton: UIButton!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        logicController.updatedProps = { [weak self] props in
            DispatchQueue.main.async {
                self?.render(props)
            }
        }
    }
    
    private func render(_ props: Props) {
        self.props = props
        _ = configureCaptureSession
        
        addNewWordButton.isHidden = !props.shouldShowAddButton
        
        guard let objectName = props.capturedObject else {
            findInDictionaryButton.isHidden = true
            objectLabel.isHidden = true
            return
        }
        
        findInDictionaryButton.isHidden = false
        objectLabel.isHidden = false
        objectLabel.text = objectName
        
        if props.shouldShowAddButton {
            addNewWordButton.setTitle(
                "There in no \(props.focusedObject) in dictionary. Tap to add",
                for: .normal
            )
        }
    }

    private lazy var configureCaptureSession: () = {
        guard let props = props else {
            return
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: props.session)
        previewLayer.videoGravity = .resizeAspect
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.frame = self.cameraLayerView.bounds
        cameraLayerView.layer.addSublayer(previewLayer)
    }()

    // MARK: - @IBActions
    @IBAction private func backButtonTouched(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func findInDictionaryTouched(_ sender: Any) {
        guard let objectName = props?.capturedObject else { return }
        findInDictionaryButton.setTitle("Find in dictionary: \(objectName)", for: .normal)
        props?.findInDictionary()
    }

    @IBAction func addNewWordButtonTouched(_ sender: Any) {
        addNewWordButton.isHidden = true
        guard let controller = UIStoryboard(name: "AddNewWord", bundle: nil)
            .instantiateViewController(withIdentifier: AddEditWordVC.reuseIdentifier) as? AddEditWordVC else { return }
        controller.newWord = props?.focusedObject
        present(controller, animated: true)
    }
}

extension ObjectDetectionVC {
    struct Props {
        let capturedObject: String?
        let focusedObject: String
        let session: AVCaptureSession
        let shouldShowAddButton: Bool
        
        let findInDictionary: () -> Void
    }
}
