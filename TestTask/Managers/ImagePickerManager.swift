//
// ImagePickerManager.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit
import AVFoundation
import Photos

protocol ImagePickerManagerDelegate: AnyObject {
    func imagePickerManager(didSelect image: UIImage, fileName: String?)
    func imagePickerManagerDidCancel()
}

final class ImagePickerManager: NSObject {
    
    weak var delegate: ImagePickerManagerDelegate?
    
    private var presentingController: UIViewController
    
    init(presentingController: UIViewController) {
        self.presentingController = presentingController
        super.init()
    }
    
    func presentPhotoSourceSelection() {
        PhotoSourceAlert.present(over: presentingController,
                                 cameraHandler: { [weak self] in self?.checkCameraAccess() },
                                 galleryHandler: { [weak self] in self?.checkGalleryAccess() })
    }
    
    private func checkCameraAccess() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    granted ? self?.presentCamera() : self?.openSettingsAlert(for: "Camera")
                }
            }
        case .denied, .restricted:
            openSettingsAlert(for: "Camera")
        @unknown default:
            presentGallery()
        }
    }
    
    private func checkGalleryAccess() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            presentGallery()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                DispatchQueue.main.async {
                    (newStatus == .authorized || newStatus == .limited) ? self?.presentGallery() : self?.openSettingsAlert(for: "Gallery")
                }
            }
        case .denied, .restricted:
            openSettingsAlert(for: "Gallery")
        @unknown default:
            presentGallery()
        }
    }
    
    private func openSettingsAlert(for accessType: String) {
        AlertView.showAlertMessage(
            title: "\(accessType) access",
            message: "To use this feature you need to allow access to your \(accessType.lowercased())",
            closeAction: "Cancel",
            action: "Open settings",
            completion: {
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else { return }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            },
            on: presentingController
        )
    }
    
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            AlertView.showError("Camera not available on this device.", on: presentingController)
            return
        }
        
        let picker = configuredImagePicker(sourceType: .camera)
        presentingController.present(picker, animated: true)
    }
    
    private func presentGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            AlertView.showError("Gallery not available on this device.", on: presentingController)
            return
        }
        
        let picker = configuredImagePicker(sourceType: .photoLibrary)
        presentingController.present(picker, animated: true)
    }
    
    private func configuredImagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        return picker
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        delegate?.imagePickerManagerDidCancel()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        let fileName = (info[.imageURL] as? URL)?.lastPathComponent
        
        if let image = selectedImage {
            delegate?.imagePickerManager(didSelect: image, fileName: fileName)
        }
    }
}

