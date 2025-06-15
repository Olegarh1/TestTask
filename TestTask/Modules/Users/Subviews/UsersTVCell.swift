//
// UsersTVCell.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

final class UsersTVCell: UITableViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel = createLabel(numberOfLines: 0, font: .setFont(.nunitoRegular, size: 18))
    private lazy var positionLabel = createLabel(font: .setFont(.nunitoRegular, size: 14), textColor: .black.withAlphaComponent(0.6))
    private lazy var emailLabel = createLabel(font: .setFont(.nunitoRegular, size: 14))
    private lazy var phoneLabel = createLabel(font: .setFont(.nunitoRegular, size: 14))
    
    private lazy var mainStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [userNameLabel, positionLabel, emailLabel, phoneLabel])
        vstack.axis = .vertical
        vstack.alignment = .leading
        vstack.spacing = 4
        vstack.setCustomSpacing(8, after: positionLabel)
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ user: UserModel) {
        setupImage(user.photo)
        userNameLabel.text = user.name
        positionLabel.text = user.position
        emailLabel.text = user.email
        phoneLabel.text = user.phone
    }
}

private extension UsersTVCell {
    func setupUI() {
        addSubview(iconImageView)
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            
            mainStack.topAnchor.constraint(equalTo: iconImageView.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func setupImage(_ urlString: String?) {
        guard let urlString = urlString,
              let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                print("⛔️ Не вдалося завантажити зображення: \(error?.localizedDescription ?? "невідома помилка")")
                return
            }
            
            DispatchQueue.main.async {
                self?.iconImageView.image = image
            }
        }.resume()
    }
    
    func createLabel(_ text: String = "", numberOfLines: Int = 1, font: UIFont, textColor: UIColor = .black) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = .left
        label.numberOfLines = numberOfLines
        label.lineBreakMode = numberOfLines == 1 ? .byTruncatingTail : .byWordWrapping
        return label
    }
}
