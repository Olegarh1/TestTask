//
// SignUpViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit
import AVFoundation
import Photos

class SignUpViewController: BaseViewController, UINavigationControllerDelegate {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var nameView = TextFieldView(type: .username, placeholder: "Your name")
    private lazy var emailView = TextFieldView(type: .email, placeholder: "Email")
    private lazy var phoneView = TextFieldView(type: .phone, placeholder: "Phone")
    
    private lazy var userDataStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [nameView, emailView, phoneView])
        vstack.axis = .vertical
        vstack.spacing = 10
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    private lazy var positionLabel: UILabel = {
        let label = UILabel()
        label.text = "Select your position"
        label.font = .setFont(.nunitoRegular, size: 18)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var positionStack: UIStackView = {
        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.spacing = 12
        vstack.alignment = .leading
        vstack.setCustomSpacing(0, after: phoneView)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    private lazy var uploadView = TextFieldView(type: .camera, placeholder: "Upload your photo")
    
    private lazy var signUpButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign up"
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.cornerStyle = .capsule
        config.baseForegroundColor = .black
        config.baseBackgroundColor = UIColor(hex: "#F4E041")
        
        let button = UIButton()
        button.configuration = config
        button.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var positions: [Position] = [] {
        didSet {
            setupPositionStack()
        }
    }
    private var selectedButton: UIButton?
    private var selectedImage: UIImage?
    private var signUpModel = SignUpRequestModel(name: "", email: "", phone: "", position_id: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavTitle("Working with POST request")
        setupUI()
        getPositions()
    }
}

private extension SignUpViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupSubviews()
        setupConstraints()
        setupTapGesture()
        setupDelegates()
    }
    
    func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [userDataStack, positionLabel, positionStack, uploadView, signUpButton].forEach {
            contentView.addSubview($0)
        }
        
        uploadView.addRightView(text: "Upload", target: self, action: #selector(uploadButtonAction))
    }
    
    func setupDelegates() {
        [nameView, emailView, phoneView, uploadView].forEach { $0.delegate = self }
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            userDataStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 64), //navigation title
            userDataStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            userDataStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            positionLabel.topAnchor.constraint(equalTo: userDataStack.bottomAnchor, constant: 32),
            positionLabel.leadingAnchor.constraint(equalTo: userDataStack.leadingAnchor),
            positionLabel.trailingAnchor.constraint(equalTo: userDataStack.trailingAnchor),
            
            positionStack.topAnchor.constraint(equalTo: positionLabel.bottomAnchor, constant: 16),
            positionStack.leadingAnchor.constraint(equalTo: userDataStack.leadingAnchor, constant: 24),
            positionStack.trailingAnchor.constraint(equalTo: userDataStack.trailingAnchor),
            
            uploadView.topAnchor.constraint(equalTo: positionStack.bottomAnchor, constant: 16),
            uploadView.leadingAnchor.constraint(equalTo: userDataStack.leadingAnchor),
            uploadView.trailingAnchor.constraint(equalTo: userDataStack.trailingAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: uploadView.bottomAnchor, constant: 16),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    func getPositions() {
        Network.shared.getPositions { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    guard let positions = model.positions, model.success,
                    let firstPositionID = positions.first?.id else {
                        AlertView.showError(model.message ?? "No position enabled", on: self)
                        return
                    }
                    self.positions = positions
                    self.signUpModel.position_id = firstPositionID
                    
                case .failure(let error):
                    AlertView.showError(error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func setupPositionStack() {
        guard positions.count > 0 else {
            positionLabel.layer.opacity = 0
            return
        }
        
        positionLabel.layer.opacity = 1
        
        for (index, model) in positions.enumerated() {
            let button = RadioButton()
            button.tag = index
            button.setTitle(model.name, for: .normal)
            button.addTarget(self, action: #selector(positionButtonAction), for: .touchUpInside)
            positionStack.addArrangedSubview(button)
            
            if index == 0 {
                button.isSelected = true
                selectedButton = button
            }
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    func isButtonEnabled(_ state: Bool) {
        signUpButton.isUserInteractionEnabled = state
        signUpButton.configuration?.baseBackgroundColor = state ? UIColor(hex: "#F4E041") : UIColor(hex: "#DEDEDE")
        signUpButton.configuration?.baseForegroundColor = state ? .black : .black.withAlphaComponent(0.48)
    }
    
    func isValidData() -> Bool {
        [nameView, emailView, phoneView, uploadView].forEach { $0.validate() }
        return [nameView, emailView, phoneView, uploadView].allSatisfy { $0.validate() }
    }

    func generateToken() {
        Network.shared.generateToken { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let token):
                    guard token.success else {
                        AlertView.showError("Failed to get user token", on: self)
                        return
                    }
                    self.registUser(token.token)
                case .failure(let error):
                    AlertView.showError(error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func registUser(_ token: String?) {
        guard let token = token else {
            AlertView.showError("Wrong token \(token ?? "null")", on: self)
            return
        }
        
        guard let image = selectedImage else {
            AlertView.showError("Wrong image", on: self)
            return
        }
        
        Network.shared.signUpUser(signUpModel, image: image, token: token) { response in
            print("Regist response is \(response)")
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    let vc = RegistrationResultViewController(success: model.success, message: model.message ?? "")
                    self.present(vc, animated: true)
                case .failure(let error):
                    AlertView.showError(error.localizedDescription, on: self)
                }
            }
        }
    }
}

@objc
private extension SignUpViewController {
    func dismissEditing() {
        view.endEditing(true)
    }
    
    func signUpButtonAction(_ sender: UIButton) {
        sender.showAnimation { [weak self] in
            guard let self = self else { return }
            guard isValidData() else { return }
            
            generateToken()
        }
    }
    
    func positionButtonAction(_ sender: UIButton) {
        guard let button = sender as? RadioButton,
              let positionID = positions[button.tag].id else { return }
        
        signUpModel.position_id = positionID
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
    }
    
    func uploadButtonAction(_ sender: UIButton) {
        sender.showAnimation {
            PhotoSourceAlert.present(over: self,
                                     cameraHandler: { [weak self] in
                self?.openCamera()
            },
                                     galleryHandler: { [weak self] in
                self?.openGallery()
            })
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[.imageURL] as? URL {
            let fileName = url.lastPathComponent
            uploadView.setText(fileName)
        } else {
            uploadView.setText("Photo.jpg")
        }
        
        if let editedImage = info[.editedImage] as? UIImage {
            handleSelectedImage(editedImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
            handleSelectedImage(originalImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func handleSelectedImage(_ image: UIImage) {
        selectedImage = image
    }
    
    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.presentCamera()
                
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                    self?.openGallery()
                }
                
            case .denied, .restricted:
                AlertView.showAlertMessage(title: "Camera access", message: "To take photo you need to acees camera", closeAction: "Cancel", action: "Open settings", completion: {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }, on: self)
                
            @unknown default:
                self.openGallery()
            }
        }
    }
    
    private func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            AlertView.showError("Camera not available on this device.", on: self)
            return
        }

        let picker = UIImagePickerController()
        picker.mediaTypes = ["public.image"]
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    private func openGallery() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        DispatchQueue.main.async {
            switch status {
            case .authorized, .limited:
                self.presentGallery()
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
                    self?.presentGallery()
                }
                
            case .denied, .restricted:
                AlertView.showAlertMessage(title: "Gallery access", message: "To select photo you need to access gallery", closeAction: "Cancel", action: "Open settings", completion: {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                    }
                }, on: self)
                
            @unknown default:
                self.presentGallery()
            }
        }
    }

    private func presentGallery() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            AlertView.showError("Gallery not available on this device.", on: self)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        present(picker, animated: true)
    }
}

extension SignUpViewController: TextFieldViewDelegate {
    func didEndEditing(_ text: String?, type: TextFieldType) {
        guard let text = text else { return }
        switch type {
        case .username:
            signUpModel.name = text
        case .email:
            signUpModel.email = text.lowercased()
        case .phone:
            signUpModel.phone = text
        default:
            break
        }
    }
}
