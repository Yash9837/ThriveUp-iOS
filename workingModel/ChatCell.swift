//
//  ChatCell.swift
//  ThriveUp
//
//  Created by palak seth on 13/11/24.
//

import UIKit
import SDWebImage

class ChatCell: UITableViewCell {
    static let identifier = "ChatCell"

    let profileImageView = UIImageView()
    let nameLabel = UILabel()
    let messageLabel = UILabel()
    let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        // Profile Image
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        contentView.addSubview(profileImageView)

        // Name Label
        nameLabel.font = .boldSystemFont(ofSize: 17)
        contentView.addSubview(nameLabel)

        // Message Label
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.textColor = .gray
        contentView.addSubview(messageLabel)

        // Time Label
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .lightGray
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)

        // Layout Constraints
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Profile Image
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),

            // Name Label
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            // Time Label
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.widthAnchor.constraint(equalToConstant: 60),

            // Message Label
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with name: String, message: String, time: String, user: User) {
        nameLabel.text = name
        messageLabel.text = message
        timeLabel.text = time

        if let image = user.profileImage {
            // Use local UIImage
            profileImageView.image = image
        } else if let urlString = user.profileImageURL, let url = URL(string: urlString) {
            // Use remote URL with SDWebImage
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
        } else {
            // Fallback to placeholder
            profileImageView.image = UIImage(named: "placeholder")
        }
    }
}
