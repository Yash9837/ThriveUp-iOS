/*import UIKit

class AddFriendsViewController: UIViewController {
    
    let searchBar = UISearchBar()
    let tableView = UITableView()
    let collectionView: UICollectionView
    let quickAddTitleLabel = UILabel() // Label for Quick Add title
    let addedMeTitleLabel = UILabel() // Label for Added Me title
    let separatorView = UIView() // Separator view between sections
    
    var friendRequests: [FriendRequest] = FriendRequest.sampleData
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Initialize the collection view with a compositional layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: AddFriendsViewController.createCompositionalLayout())
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupNavigationBar()
        setupSearchBar()
        setupAddedMeTitleLabel() // Set up Added Me title
        setupTableView()
        setupSeparatorView() // Add separator view setup
        setupQuickAddTitleLabel() // Set up Quick Add title label
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Add Friends"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24) // Increase font size of Add Friends
        ]
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissViewController))
        cancelButton.tintColor = .systemOrange
        navigationItem.rightBarButtonItem = cancelButton
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(dismissViewController))
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.1)
        }
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupAddedMeTitleLabel() {
        addedMeTitleLabel.text = "Added Me"
        addedMeTitleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        addedMeTitleLabel.textColor = .black
        
        view.addSubview(addedMeTitleLabel)
        addedMeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addedMeTitleLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            addedMeTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "FriendRequestCell")
        tableView.rowHeight = 80 // Adjust height for Accept and Reject button layout
        tableView.tableFooterView = UIView()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addedMeTitleLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 250) // Set a fixed height for "Added Me" section
        ])
    }
    
    private func setupSeparatorView() {
        separatorView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        view.addSubview(separatorView)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupQuickAddTitleLabel() {
        quickAddTitleLabel.text = "Quick Add"
        quickAddTitleLabel.font = UIFont.boldSystemFont(ofSize: 20) // Match Added Me font size
        quickAddTitleLabel.textColor = .black
        
        view.addSubview(quickAddTitleLabel)
        quickAddTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            quickAddTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            quickAddTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(QuickAddCollectionViewCell.self, forCellWithReuseIdentifier: "QuickAddCell")
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = true // Enable horizontal scroll
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: quickAddTitleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 340) // Adjusted height for two rows
        ])
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Compositional Layout for 2x2 Grid
    static func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(160)) // Height for two rows
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let doubleGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .absolute(320)) // Two rows total
        let doubleGroup = NSCollectionLayoutGroup.vertical(layoutSize: doubleGroupSize, subitems: [group, group])
        
        let section = NSCollectionLayoutSection(group: doubleGroup)
        section.orthogonalScrollingBehavior = .groupPaging // Allows for paging horizontally
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension AddFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Added Me"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequests.filter { !$0.isQuickAdd }.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendRequestCell", for: indexPath) as? FriendRequestCell else {
            return UITableViewCell()
        }
        
        let addedMeRequests = friendRequests.filter { !$0.isQuickAdd }
        let friendRequest = addedMeRequests[indexPath.row]
        
        cell.configure(
            with: friendRequest.name,
            username: friendRequest.username,
            profileImage: friendRequest.profileImage,
            actionTitle: friendRequest.actionTitle,
            showRejectButton: true // Show cross button
        )
        
        return cell
    }
}

extension AddFriendsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendRequests.filter { $0.isQuickAdd }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuickAddCell", for: indexPath) as? QuickAddCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let quickAddRequests = friendRequests.filter { $0.isQuickAdd }
        let friendRequest = quickAddRequests[indexPath.row]
        
        cell.configure(with: friendRequest)
        
        return cell
    }
}

*/
