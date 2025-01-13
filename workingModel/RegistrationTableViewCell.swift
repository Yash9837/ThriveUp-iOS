//
//  RegistrationTableViewCell.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 09/01/25.
//


import UIKit

class RegistrationTableViewCell: UITableViewCell {
    
    static let identifier = "RegistrationTableViewCell"
    
    // MARK: - UI Components
    private let serialNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.textAlignment = .left
        return label
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(serialNumberLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(yearLabel)
        
        serialNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Serial Number
            serialNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            serialNumberLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            serialNumberLabel.widthAnchor.constraint(equalToConstant: 50),
            
            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: serialNumberLabel.trailingAnchor, constant: 8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: yearLabel.leadingAnchor, constant: -8),
            
            // Email Label (under name)
            emailLabel.leadingAnchor.constraint(equalTo: serialNumberLabel.trailingAnchor, constant: 8),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: yearLabel.leadingAnchor, constant: -8),
            emailLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
            
            // Year Label
            yearLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            yearLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            yearLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with registration: [String: Any], index: Int) {
        serialNumberLabel.text = "\(index + 1)"
        nameLabel.text = registration["Name"] as? String
        emailLabel.text = registration["E-mail ID"] as? String
        yearLabel.text = registration["Year of Study"] as? String
    }
}

