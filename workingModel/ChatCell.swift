import UIKit

class ChatCell: UITableViewCell {
    static let identifier = "ChatCell"
    
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(timeLabel)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.image = UIImage(named: "defaultProfileImage") // Placeholder image
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .darkGray
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .lightGray
        
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 50),
            profileImageView.heightAnchor.constraint(equalToConstant: 50),
            
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with name: String, message: String, time: String, profileImageURL: String?) {
        nameLabel.text = name
        messageLabel.text = message
        timeLabel.text = time
        
        if let urlString = profileImageURL, let url = URL(string: urlString) {
            // Asynchronously load the profile image
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.profileImageView.image = image
                    }
                }
            }
        } else {
            profileImageView.image = UIImage(named: "defaultProfileImage") // Placeholder image
        }
    }
}
