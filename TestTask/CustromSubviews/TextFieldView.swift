//
// TextFieldView.swift
// TestTask
//
// Created by Oleg Zakladnyi on 21.06.2025

import UIKit

enum TextFieldType {
    case username
    case email
    case phone
    case camera
}

protocol TextFieldViewDelegate: AnyObject {
    func didEndEditing(_ text: String?, type: TextFieldType)
}

class TextFieldView: UIView {
    
    weak var delegate: TextFieldViewDelegate?
    
    private lazy var textField: UITextField = {
        let textField: UITextField = UITextField()
        textField.placeholder = placeholderText
        textField.font = customFont
        textField.keyboardType = textFieldType == .phone ? .numberPad : .default
        textField.delegate = self
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 1
        textField.layer.borderColor = borderColor
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let paddingViewLeft = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.leftView = paddingViewLeft
        textField.leftViewMode = .always
        
        let paddingViewRight = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 56))
        textField.rightView = paddingViewRight
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "Required field"
        label.textColor = errorColor
        label.font = .setFont(.nunitoRegular, size: 14)
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderText: String
    private let customFont: UIFont
    private let textFieldType: TextFieldType
    
    private let errorColor = UIColor(hex: "#CB3D40")
    private let borderColor = UIColor(hex: "#D0CFCF").cgColor
    
    init(type: TextFieldType, placeholder: String, font: UIFont = .setFont(.nunitoRegular, size: 18)) {
        self.textFieldType = type
        self.placeholderText = placeholder
        self.customFont = font
        super.init(frame: .zero)
        setupUI()
        setupLabelForPhone()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addRightView(text: String, target: Any?, action: Selector) {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.setTitleColor(UIColor(hex: "#009BBD"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: button.frame.width + 16, height: 56))
        button.frame.origin = CGPoint(x: 0, y: (56 - button.frame.height) / 2)
        container.addSubview(button)
        
        textField.rightView = container
        textField.rightViewMode = .always
    }
    
    func setText(_ text: String) {
        textField.text = text
        hideError()
    }
    
    func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.textColor = errorColor
        errorLabel.alpha = 1
        textField.textColor = errorColor
        textField.layer.borderColor = errorColor.cgColor
    }
    
    func hideError() {
        errorLabel.alpha = 0
        textField.textColor = .black
        textField.layer.borderColor = borderColor
        
        setupLabelForPhone()
    }
    
    @discardableResult
    func validate() -> Bool {
        switch textFieldType {
        case .username:
            return validateUsername()
        case .email:
            return validateEmail()
        case .phone:
            return validatePhone()
        case .camera:
            return validateCamera()
        }
    }
}

private extension TextFieldView {
    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(textField)
        addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 56),
            
            errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 4),
            errorLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            errorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupLabelForPhone() {
        guard textFieldType == .phone else { return }
        
        errorLabel.text = "+38 (XXX) XXX - XX - XX"
        errorLabel.alpha = 1
        errorLabel.textColor = .black.withAlphaComponent(0.6)
    }
}

extension TextFieldView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        hideError()
        guard textFieldType != .camera else { return false }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textFieldType {
        case .username:
            validateUsername()
        case .email:
            validateEmail()
        case .phone:
            validatePhone()
        case .camera:
            validateCamera()
        }
        delegate?.didEndEditing(textField.text, type: textFieldType)
    }
    
    @discardableResult
    private func validateUsername() -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            showError("Required field")
            return false
        }
        
        if text.count < 3 {
            showError("Username too short")
            return false
        }
        
        hideError()
        return true
    }

    @discardableResult
    private func validateEmail() -> Bool {
        guard let email = textField.text, !email.isEmpty else {
            showError("Required field")
            return false
        }

        let regexPattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#

        do {
            let regex = try NSRegularExpression(pattern: regexPattern, options: [.caseInsensitive])
            let range = NSRange(location: 0, length: email.utf16.count)
            if regex.firstMatch(in: email, options: [], range: range) == nil {
                showError("User email must be valid (RFC2822)")
                return false
            } else {
                hideError()
                return true
            }
        } catch {
            print("Regex error: \(error)")
            showError("Internal validation error")
            return false
        }
    }

    @discardableResult
    private func validatePhone() -> Bool {
        guard let phone = textField.text, !phone.isEmpty else {
            showError("Required field")
            return false
        }
        
        let phoneRegEx = #"^\+380\d{9}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        
        if !predicate.evaluate(with: phone) {
            showError("Invalid phone format. Format is +380XXXXXXXXX")
            return false
        }
        
        hideError()
        return true
    }
    
    @discardableResult
    private func validateCamera() -> Bool {
        guard let text = textField.text, !text.isEmpty else {
            showError("Required field")
            return false
        }
        
        return true
    }
}
