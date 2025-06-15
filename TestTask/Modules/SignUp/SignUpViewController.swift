//
// SignUpViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

class SignUpViewController: BaseViewController {
    
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
    
    private lazy var nameTextFiled = createTextField(placeholder: "Your name")
    private lazy var emailTextFiled = createTextField(placeholder: "Email")
    private lazy var phoneTextFiled = createTextField(placeholder: "Phone")
    
    private lazy var phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "+38 (XXX) XXX - XX - XX"
        label.font = .setFont(.nunitoRegular, size: 14)
        label.textColor = .black.withAlphaComponent(0.6)
        label.textAlignment = .left
        return label
    }()
    
    private lazy var userDataStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [nameTextFiled, emailTextFiled, phoneTextFiled, phoneLabel])
        vstack.axis = .vertical
        vstack.spacing = 32
        vstack.setCustomSpacing(0, after: phoneTextFiled)
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
        vstack.setCustomSpacing(0, after: phoneTextFiled)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    private lazy var uploadTextFiled = createTextField(placeholder: "Upload your photo")
    
    private lazy var signUpButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Sign up"
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.cornerStyle = .capsule
        config.baseForegroundColor = .black
        config.baseBackgroundColor = UIColor(hex: "#F4E041")
        
        let button = UIButton()
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var positions: [Position] = [] {
        didSet {
            setupPositionStack()
        }
    }
    private var selectedButton: UIButton?
    
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
    }
    
    func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [userDataStack, positionLabel, positionStack, uploadTextFiled, signUpButton].forEach {
            contentView.addSubview($0)
        }
        
        uploadTextFiled.isUserInteractionEnabled = false
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
            
            uploadTextFiled.topAnchor.constraint(equalTo: positionStack.bottomAnchor, constant: 16),
            uploadTextFiled.leadingAnchor.constraint(equalTo: userDataStack.leadingAnchor),
            uploadTextFiled.trailingAnchor.constraint(equalTo: userDataStack.trailingAnchor),
            
            signUpButton.topAnchor.constraint(equalTo: uploadTextFiled.bottomAnchor, constant: 16),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    func getPositions() {
        Network.shared.getPositions { response in
            DispatchQueue.main.async {
                switch response {
                case .success(let model):
                    guard let positions = model.positions, model.success else {
                        AlertView.showError(model.message ?? "No position enabled", on: self)
                        return
                    }
                    self.positions = positions
                    
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
    
    func createTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.font = .setFont(.nunitoRegular, size: 18)
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(hex: "#D0CFCF").cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.leftView = paddingViewLeft
        textField.leftViewMode = .always
        
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = paddingViewRight
        textField.rightViewMode = .always
        
        return textField
    }

    @objc
    func positionButtonAction(_ sender: UIButton) {
        guard let button = sender as? RadioButton else { return }

        selectedButton?.isSelected = false
        button.isSelected = true
        selectedButton = button
    }
}
