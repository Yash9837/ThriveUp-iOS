/*//
//  FriendRequestCell.swift
//  ThriveUp
//
//  Created by palak seth on 14/11/24.
//

import UIKit

class FriendRequestCell: UITableViewCell {
    
    // UI Elements
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let usernameLabel = UILabel()
    let acceptButton = UIButton(type: .system)
    let rejectButton = UIButton(type: .system) // Cross button
    
    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set up cell with UI components and constraints
    private func setupCell() {
        
        // Profile Image Setup
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        contentView.addSubview(profileImageView)
        
        // Name Label Setup
        nameLabel.font = .boldSystemFont(ofSize: 16)
        contentView.addSubview(nameLabel)
        
        // Username Label Setup
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.textColor = .gray
        contentView.addSubview(usernameLabel)
        
        // Accept Button Setup
        acceptButton.setTitle("Accept", for: .normal)
        acceptButton.backgroundColor = .systemOrange
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.layer.cornerRadius = 15
        contentView.addSubview(acceptButton)
        
        // Reject (Cross) Button Setup
        rejectButton.setTitle("✕", for: .normal)
        rejectButton.setTitleColor(.systemGray, for: .normal)
        rejectButton.backgroundColor = .clear
        contentView.addSubview(rejectButton)
        
        // Layout Constraints
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Profile Image Constraints
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Name Label Constraints
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            
            // Username Label Constraints
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            usernameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            // Accept Button Constraints
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            acceptButton.widthAnchor.constraint(equalToConstant: 80),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
            
            // Reject Button Constraints
            rejectButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rejectButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -8),
            rejectButton.widthAnchor.constraint(equalToConstant: 30),
            rejectButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    // Configure cell with data
    func configure(with name: String, username: String, profileImage: UIImage?, actionTitle: String, showRejectButton: Bool) {
        nameLabel.text = name
        usernameLabel.text = username
        profileImageView.image = profileImage
        acceptButton.setTitle(actionTitle, for: .normal)
        rejectButton.isHidden = !showRejectButton // Hide or show the reject button based on parameter
    }
}
*/

