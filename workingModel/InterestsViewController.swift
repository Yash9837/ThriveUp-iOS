import UIKit
import Firebase
import FirebaseFirestore


class InterestsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // User ID property
    var userID: String?

    // Data structure for interests
    private let interests: [String: [String]] = [
        "Creativity": ["Art 🎨", "Design ✏️", "Make-up 💄", "Photography 📸", "Writing 📝", "Singing 🎤", "Dancing 💃", "Crafts 📎", "Making videos 📼"],
        "Sports": ["Yoga 🧘", "Running 👟", "Gym 🏋️", "Soccer ⚽", "Cricket 🏏", "Tennis 🎾", "Badminton 🏸", "Basketball 🏀"],
        "Date Preference": ["Weekday 📅", "Weekend 🌞"],
        "Categories": ["Tech 💻", "Fun 🎉", "Entertainment 🎭", "Wellness 🧘‍♀️", "Networking 🤝", "Cultural 🎨", "Student Clubs 👩‍🎓"],
        "Participants": ["Solo 🧍", "Duo 👫", "Team 👥"]
    ]

    private var selectedInterests = [String]()
    private let maxSelection = 10

    private var collectionView: UICollectionView!

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Interests"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Pick up to 10 things you love. It’ll help you match with the right events for you."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.text = "0/10 selected"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setupNavigationBar()
        setupHeader()
        setupCollectionView()
        setupConstraints()
        
        // Fetch saved interests for the user
        fetchSavedInterests()
    }
    
    private func setupNavigationBar() {
        // Change back button to orange
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .systemOrange
        navigationItem.leftBarButtonItem = backButton
    }

    private func setupHeader() {
        view.addSubview(headerLabel)
        view.addSubview(subHeaderLabel)
        view.addSubview(selectionLabel)
        view.addSubview(saveButton)
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            section.boundarySupplementaryItems = [header]

            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(InterestCell.self, forCellWithReuseIdentifier: "InterestCell")
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        view.addSubview(collectionView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 8),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            selectionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            selectionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            collectionView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: selectionLabel.topAnchor, constant: -16),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func saveButtonTapped() {
        saveInterestsToFirestore()
    }

    @objc private func backButtonTapped() {
        navigateToSwipeViewController()
    }

    private func saveInterestsToFirestore() {
        guard let userID = userID else {
            print("User ID is nil") // Debugging statement
            return
        }

        let db = Firestore.firestore()
        let userInterests = ["userID": userID, "interests": selectedInterests] as [String : Any]

        db.collection("Interest").document(userID).setData(userInterests) { error in
            if let error = error {
                print("Error saving interests: \(error.localizedDescription)") // Debugging statement
                return
            }
            print("Interests saved successfully.") // Debugging statement
            
            // Show an alert controller confirming the interests have been saved
            let alertController = UIAlertController(title: "Success", message: "Your interests have been saved.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.navigateToSwipeViewController()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

    private func navigateToSwipeViewController() {
        // Assuming the SwipeViewController is the initial view controller
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "hasLoggedInBefore")
        
        // Notify SwipeViewController to show the instructions
        NotificationCenter.default.post(name: NSNotification.Name("ShowInstructions"), object: nil)
        
        navigationController?.popViewController(animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            navigateToSwipeViewController()
        }
    }

    // Fetch saved interests from Firestore
    private func fetchSavedInterests() {
        guard let userID = userID else {
            print("User ID is nil") // Debugging statement
            return
        }

        let db = Firestore.firestore()
        db.collection("Interest").document(userID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching saved interests: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("No saved interests found for user \(userID)") // Debugging statement
                return
            }

            self?.selectedInterests = data["interests"] as? [String] ?? []
            self?.selectionLabel.text = "\(self?.selectedInterests.count ?? 0)/\(self?.maxSelection ?? 10) selected"
            self?.collectionView.reloadData()
        }
    }

    // MARK: - UICollectionView DataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return interests.keys.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = Array(interests.keys)[section]
        return interests[category]?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let category = Array(interests.keys)[indexPath.section]
        let item = interests[category]?[indexPath.row] ?? ""

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestCell", for: indexPath) as! InterestCell
        cell.configure(with: item, isSelected: selectedInterests.contains(item))
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = Array(interests.keys)[indexPath.section]
        let selectedItem = interests[category]?[indexPath.row] ?? ""

        if let index = selectedInterests.firstIndex(of: selectedItem) {
            selectedInterests.remove(at: index)
        } else if selectedInterests.count < maxSelection {
            selectedInterests.append(selectedItem)
        } else {
            let alert = UIAlertController(title: "Limit Reached", message: "You can only select up to \(maxSelection) interests.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }

        collectionView.reloadData()
        selectionLabel.text = "\(selectedInterests.count)/\(maxSelection) selected"
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeader
        let category = Array(interests.keys)[indexPath.section]
        header.configure(with: category)
        return header
    }
}

// Custom UICollectionViewCell for Interest
class InterestCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true

        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String, isSelected: Bool) {
        label.text = text
        contentView.backgroundColor = isSelected ? .systemOrange : .white
        contentView.layer.borderColor = isSelected ? UIColor.systemOrange.cgColor : UIColor.lightGray.cgColor
        label.textColor = isSelected ? .white : .black
    }
}

// Custom Header View for Section
class SectionHeader: UICollectionReusableView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        label.text = text
    }
}


