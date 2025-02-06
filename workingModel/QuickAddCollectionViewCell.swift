/*//
//  QuickAddCollectionViewCell.swift
//  ThriveUp
//
//  Created by palak seth on 14/11/24.
//

import UIKit

class QuickAddCollectionViewCell: UICollectionViewCell {
    
    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let actionButton = UIButton(type: .system)
    let networkingLabel = UILabel() // "Networking" label for additional information
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupCellAppearance()
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Appearance
    private func setupCellAppearance() {
        // Style the cell as a bordered box with rounded corners
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    // MARK: - Setup Subviews
    private func setupSubviews() {
        // Profile Image
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)
        
        // Name Label
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        
        // Networking Label
        networkingLabel.text = "Networking"
        networkingLabel.font = .systemFont(ofSize: 12)
        networkingLabel.textColor = .gray
        networkingLabel.textAlignment = .center
        contentView.addSubview(networkingLabel)
        
        // Action Button
        actionButton.setTitle("ADD", for: .normal)
        actionButton.backgroundColor = .systemOrange
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.layer.cornerRadius = 10
        contentView.addSubview(actionButton)
    }
    
    // MARK: - Setup Constraints
    private func setupConstraints() {
        // Disable autoresizing mask constraints for all subviews
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        networkingLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Profile Image Constraints
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Name Label Constraints
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Networking Label Constraints
            networkingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            networkingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            networkingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Action Button Constraints
            actionButton.topAnchor.constraint(equalTo: networkingLabel.bottomAnchor, constant: 4),
            actionButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            actionButton.heightAnchor.constraint(equalToConstant: 25),
//            actionButton.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configure Cell
    func configure(with friendRequest: FriendRequest) {
        profileImageView.image = friendRequest.profileImage
        nameLabel.text = friendRequest.name
    }
}


*/
