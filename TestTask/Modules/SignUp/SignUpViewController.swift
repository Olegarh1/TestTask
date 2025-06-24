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
        label.alpha = 0
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
    
    private lazy var signUpButton = ButtonDefault(title: "Sign up", target: self, action: #selector(signUpButtonAction))
    
    private var positions: [Position] = [] {
        didSet {
            setupPositionStack()
        }
    }
    
    private lazy var imagePickerManager = ImagePickerManager(presentingController: self)
    
    private var selectedButton: UIButton?
    private var selectedImage: UIImage?
    private var signUpModel = SignUpRequestModel(name: "", email: "", phone: "", position_id: 0, photo: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavTitle("Working with POST request")
        setupUI()
        getPositions()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .registrationSuccess, object: nil)
    }
}

private extension SignUpViewController {
    func setupUI() {
        view.backgroundColor = .white
        setupSubviews()
        setupConstraints()
        setupTapGesture()
        setupDelegates()
        isButtonEnabled(false)
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
        
        imagePickerManager.delegate = self
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
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            signUpButton.widthAnchor.constraint(lessThanOrEqualToConstant: 140),
            signUpButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    func getPositions(retryCount: Int = 3, delay: TimeInterval = 2) {
        guard NetworkMonitor.shared.isConnected else {
            NetworkMonitor.shared.runWhenConnected {
                self.getPositions(retryCount: retryCount, delay: delay)
            }
            return
        }

        Network.shared.getPositions { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    guard let positions = model.positions, model.success,
                          let firstPositionID = positions.first?.id else {
                        AlertView.showError(model.message ?? "No position enabled", on: self)
                        return
                    }
                    self.positionLabel.alpha = 1
                    self.positions = positions
                    self.signUpModel.position_id = firstPositionID
                    
                case .failure(let error):
                    if retryCount > 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.getPositions(retryCount: retryCount - 1, delay: delay)
                        }
                    } else {
                        AlertView.showError(error.localizedDescription, on: self)
                    }
                }
            }
        }
    }
    
    func setupPositionStack() {
        positionStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
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
        let fields = [nameView, emailView, phoneView, uploadView]
        fields.forEach { $0.validate() }
        return fields.allSatisfy { $0.validate() }
    }

    func generateToken() {
        showLoader(true)
        
        Network.shared.generateToken { response in
            DispatchQueue.main.async { [self] in
                switch response {
                case .success(let token):
                    guard token.success else {
                        self.showLoader(false)
                        AlertView.showError("Failed to get user token", on: self)
                        return
                    }
                    self.registUser(token.token)
                case .failure(let error):
                    self.showLoader(false)
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
            DispatchQueue.main.async {
                self.showLoader(false)
                switch response {
                case .success(let model):
                    self.sendObserver(model.success)
                    var message = model.message ?? ""
                    if let fails = model.fails {
                        let detailedErrors = fails.flatMap { $0.value }.joined(separator: "\n")
                        message = detailedErrors
                    }
                    let vc = RegistrationResultViewController(success: model.success, message: message)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                case .failure(let error):
                    AlertView.showError(error.localizedDescription, on: self)
                }
            }
        }
    }
    
    func sendObserver(_ success: Bool) {
        guard success else { return }
        NotificationCenter.default.post(name: .registrationSuccess, object: nil)
    }
    
    func showLoader(_ state: Bool) {
        if state {
            signUpButton.showLoaderInsteadOfcontent()
        } else {
            signUpButton.hideLoaderAndRestoreContent()
        }
    }
}

@objc
private extension SignUpViewController {
    func dismissEditing() {
        view.endEditing(true)
    }
    
    @objc func signUpButtonAction(_ sender: UIButton) {
        dismissEditing()
        sender.showAnimation { [weak self] in
            self?.submitSignUpForm()
        }
    }

    private func submitSignUpForm() {
        guard isValidData() else { return }
        generateToken()
    }
    
    func positionButtonAction(_ sender: UIButton) {
        dismissEditing()
        guard let button = sender as? RadioButton,
              let positionID = positions[button.tag].id else { return }
        
        signUpModel.position_id = positionID
        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
    }
    
    func uploadButtonAction(_ sender: UIButton) {
        sender.showAnimation {
            self.imagePickerManager.presentPhotoSourceSelection()
        }
    }
}

extension SignUpViewController: ImagePickerManagerDelegate {
    func imagePickerManager(didSelect image: UIImage, fileName: String?) {
        selectedImage = image
        uploadView.setText(fileName ?? "Photo.jpg")
    }
    
    func imagePickerManagerDidCancel() {
        print("User cancel selection")
    }
}

extension SignUpViewController: TextFieldViewDelegate {
    func didEndEditing(_ text: String?, type: TextFieldType) {
        isButtonEnabled(true)
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
