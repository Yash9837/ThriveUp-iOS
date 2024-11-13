//
//  SpeakerCell.swift
//  workingModel
//
//  Created by Yash's Mackbook on 13/11/24.
//

import UIKit

class SpeakerCell: UICollectionViewCell {
    static let identifier = "SpeakerCell"
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)

        // Set up image view and label constraints
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        nameLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.textAlignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with speaker: Speaker) {
        nameLabel.text = speaker.name
        imageView.image = UIImage(named: speaker.imageURL)
        // Set a placeholder image initially
        
        
        // Load image from speaker.imageURL
        
    }
}
