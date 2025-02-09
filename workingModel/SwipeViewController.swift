import UIKit
import Instructions
import FirebaseFirestore
import FirebaseAuth

class SwipeViewController: UIViewController, CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    private var eventStack: [EventModel] = []
    private var bookmarkedEvents: [EventModel] = []
    private let db = Firestore.firestore()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // CoachMarksController instance for the guided tour
    let coachMarksController = CoachMarksController()
    let titleLabel = UILabel()
    let titleStackView = UIStackView()
    let filterButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGray6
        
        setupTitleStackView()
        setupViews()
        setupConstraints()
        fetchEventsFromDatabase()
        
        // Configure CoachMarksController
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        
        // Check if it's the user's first time logging in
        if isFirstTimeUser() {
            askForTutorial()
        }
        
        // Observe for notification to show the instructions
        NotificationCenter.default.addObserver(self, selector: #selector(showInstructions), name: NSNotification.Name("ShowInstructions"), object: nil)
    }
    
    @objc private func showInstructions() {
        askForTutorial()
    }

    private func setupTitleStackView() {
        // Configure titleLabel
        titleLabel.text = "Swipe"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .left

        // Configure filterButton
        filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(handleFilterButtonTapped), for: .touchUpInside)

        // Configure titleStackView
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 8

        // Add titleLabel and filterButton to titleStackView
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(filterButton)

        // Add titleStackView to the view
        view.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func handleFilterButtonTapped() {
        guard let userId = Auth.auth().currentUser?.uid else {
            promptUserToSignIn()
            return
        }

        let interestViewController = InterestsViewController()
        interestViewController.userID = userId
        navigationController?.pushViewController(interestViewController, animated: true)
    }

    private func promptUserToSignIn() {
        let alert = UIAlertController(title: "Sign In Required", message: "Please sign in to access your interests", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Sign In", style: .default, handler: { _ in
            // Navigate to sign-in view controller
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupViews() {
        view.addSubview(cardContainerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 8),
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            cardContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func fetchEventsFromDatabase() {
        db.collection("events").getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching events: \(error.localizedDescription)")
                return
            }
            
            var fetchedEvents: [EventModel] = []
            
            snapshot?.documents.forEach { document in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                    let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
                    fetchedEvents.append(event)
                } catch {
                    print("Error decoding event: \(error.localizedDescription)")
                }
            }
            
            self?.eventStack = fetchedEvents.reversed()
            
            DispatchQueue.main.async {
                self?.displayTopCards()
            }
        }
    }
    
    private func displayTopCards() {
        cardContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        for (index, event) in eventStack.suffix(3).enumerated() {
            let cardView = createCard(for: event)
            cardContainerView.addSubview(cardView)
            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                cardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
                cardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
                cardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
                cardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
            ])
            
            cardContainerView.sendSubviewToBack(cardView)
        }
    }
    
    private func createCard(for event: EventModel) -> UIView {
        let cardView = FlippableCardView(event: event)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        cardView.addGestureRecognizer(panGesture)
        
        let bookmarkButton = createButton(imageName: "bookmark.fill", tintColor: .systemOrange)
        let discardButton = createButton(imageName: "xmark", tintColor: .systemRed)
        
        bookmarkButton.alpha = 0 // Initially hide the bookmark button
        discardButton.alpha = 0 // Initially hide the discard button
        
        cardView.addSubview(bookmarkButton)
        cardView.addSubview(discardButton)
        
        NSLayoutConstraint.activate([
            bookmarkButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            bookmarkButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 60),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 60),
            
            discardButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            discardButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            discardButton.widthAnchor.constraint(equalToConstant: 60),
            discardButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        cardView.bookmarkButton = bookmarkButton
        cardView.discardButton = discardButton
        
        return cardView
    }
    
    private func createButton(imageName: String, tintColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = tintColor
        button.backgroundColor = UIColor(white: 1, alpha: 0.75)
        button.layer.cornerRadius = 30
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? FlippableCardView else { return }
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x
        
        switch gesture.state {
        case .began:
            // Hide both buttons initially
            cardView.bookmarkButton?.alpha = 0
            cardView.discardButton?.alpha = 0
        case .changed:
            cardView.transform = CGAffineTransform(translationX: xFromCenter, y: 0)
                .rotated(by: xFromCenter / 200)
            cardView.alpha = 1 - abs(xFromCenter) / view.frame.width
            
            // Show the appropriate button based on swipe direction
            if xFromCenter > 0 {
                cardView.bookmarkButton?.alpha = 1
                cardView.discardButton?.alpha = 0
            } else {
                cardView.bookmarkButton?.alpha = 0
                cardView.discardButton?.alpha = 1
            }
            
        case .ended:
            if xFromCenter > 100 {
                bookmarkEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: true)
            } else if xFromCenter < -100 {
                discardEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: false)
            } else {
                UIView.animate(withDuration: 0.3) {
                    cardView.transform = CGAffineTransform.identity
                    cardView.alpha = 1
                    cardView.bookmarkButton?.alpha = 0
                    cardView.discardButton?.alpha = 0
                }
            }
        default:
            UIView.animate(withDuration: 0.3) {
                cardView.transform = CGAffineTransform.identity
                cardView.alpha = 1
                cardView.bookmarkButton?.alpha = 0
                cardView.discardButton?.alpha = 0
            }
        }
    }

    private func animateCardOffScreen(_ cardView: FlippableCardView, toRight: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            let direction: CGFloat = toRight ? 1 : -1
            cardView.transform = CGAffineTransform(translationX: direction * self.view.frame.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            cardView.removeFromSuperview()
            self.displayTopCards()
        }
    }

    private func bookmarkEvent(for event: EventModel) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }

        let eventData: [String: Any] = [
            "userId": userId,
            "eventId": event.eventId
        ]
        
        db.collection("swipedeventsdb").addDocument(data: eventData) { error in
            if let error = error {
                print("Error saving bookmarked event: \(error.localizedDescription)")
            }
        }
        
        eventStack.removeAll { $0.eventId == event.eventId }
        displayTopCards()
    }

    private func fetchBookmarkedEvents() -> [EventModel] {
        if let data = UserDefaults.standard.data(forKey: "bookmarkedEvents1"),
           let decodedEvents = try? JSONDecoder().decode([EventModel].self, from: data) {
            return decodedEvents
        }
        return []
    }

    private func saveBookmarkedEvents(_ events: [EventModel]) {
        if let encodedData = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encodedData, forKey: "bookmarkedEvents1")
        }
    }
    
    private func discardEvent(for event: EventModel) {
        eventStack.removeAll { $0.eventId == event.eventId }
        displayTopCards()
    }

    // Check if it's the user's first time
    private func isFirstTimeUser() -> Bool {
        guard let userId = Auth.auth().currentUser?.uid else {
            return false
        }
        return !UserDefaults.standard.bool(forKey: "hasSeenGuidedTour_\(userId)")
    }
    
    private func askForTutorial() {
        let alert = UIAlertController(title: "Welcome!", message: "Would you like to take a quick tour of the app?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.setHasSeenGuidedTour()
            self.startGuidedTour()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            self.setHasSeenGuidedTour()
        }))
        present(alert, animated: true, completion: nil)
    }

    private func setHasSeenGuidedTour() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        UserDefaults.standard.set(true, forKey: "hasSeenGuidedTour_\(userId)")
    }
    
    // Start the guided tour
    func startGuidedTour() {
        coachMarksController.start(in: .window(over: self))
    }

    // MARK: - CoachMarksControllerDataSource
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3 // Number of steps in the tour
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        switch index {
        case 0:
            return coachMarksController.helper.makeCoachMark(for: titleStackView)
        case 1:
            return coachMarksController.helper.makeCoachMark(for: filterButton)
        case 2:
            return coachMarksController.helper.makeCoachMark(for: cardContainerView)
        default:
            return coachMarksController.helper.makeCoachMark()
        }
    }

    func coachMarksController(
        _ coachMarksController: CoachMarksController,
        coachMarkViewsAt index: Int,
        madeFrom coachMark: CoachMark
    ) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        // Create the default coach views using the library's helper method
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(
            withArrow: true,
            arrowOrientation: coachMark.arrowOrientation
        )

        // Customize the coach views based on the index
        switch index {
        case 0:
            coachViews.bodyView.hintLabel.text = "This is the Swipe screen and Edit Interests button."
            coachViews.bodyView.nextLabel.text = "Next"
        case 1:
            coachViews.bodyView.hintLabel.text = "This is the Edit Interests button."
            coachViews.bodyView.nextLabel.text = "Next"
        case 2:
            coachViews.bodyView.hintLabel.text = "Swipe left to dismiss and right to bookmark events."
            coachViews.bodyView.nextLabel.text = "Got it!"
        default:
            break
        }

        // Return the customized coach views
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

class FlippableCardView: UIView, UITableViewDataSource, UITableViewDelegate {
    private var isFlipped = false
    private let frontView = UIView()
    private let backView = UIView()
    private let gradientLayer = CAGradientLayer()
    let event: EventModel

    var bookmarkButton: UIButton?
    var discardButton: UIButton?

    private let detailItems: [(String, String)]

    init(event: EventModel) {
        self.event = event
        self.detailItems = [
            ("calendar", event.date),
            ("clock", event.time),
            ("location", event.location),
            ("person.2", "Organizer: \(event.organizerName)"),
            ("text.bubble", event.description ?? "No description available.")
        ]
        
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = backView.bounds
    }

    private func setupViews() {
        setupFrontView()
        setupBackView()

        addSubview(frontView)
        addSubview(backView)

        frontView.translatesAutoresizingMaskIntoConstraints = false
        backView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            frontView.topAnchor.constraint(equalTo: topAnchor),
            frontView.leadingAnchor.constraint(equalTo: leadingAnchor),
            frontView.trailingAnchor.constraint(equalTo: trailingAnchor),
            frontView.bottomAnchor.constraint(equalTo: bottomAnchor),

            backView.topAnchor.constraint(equalTo: topAnchor),
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        backView.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(flipCard))
        addGestureRecognizer(tapGesture)
    }

    private func setupFrontView() {
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 20
        frontView.layer.shadowColor = UIColor.black.cgColor
        frontView.layer.shadowOpacity = 0.3
        frontView.layer.shadowOffset = CGSize(width: 0, height: 5)
        frontView.layer.shadowRadius = 10
        frontView.layer.masksToBounds = false

        let imageView = UIImageView(image: UIImage(named: event.imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.translatesAutoresizingMaskIntoConstraints = false
        frontView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: frontView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: frontView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: frontView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: frontView.bottomAnchor)
        ])
    }

    private func setupBackView() {
        backView.backgroundColor = .clear
        backView.layer.cornerRadius = 20
        backView.layer.masksToBounds = true

        gradientLayer.colors = [UIColor.systemOrange.cgColor, UIColor.systemRed.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.cornerRadius = 20
        backView.layer.insertSublayer(gradientLayer, at: 0)

        let titleLabel = UILabel()
        titleLabel.text = event.title
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 20
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .singleLine
        tableView.delegate = self
        tableView.dataSource = self
                tableView.register(DetailCell.self, forCellReuseIdentifier: "DetailCell")

                backView.addSubview(titleLabel)
                backView.addSubview(tableView)

                NSLayoutConstraint.activate([
                    titleLabel.topAnchor.constraint(equalTo: backView.topAnchor, constant: 32),
                    titleLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
                    titleLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),

                    tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                    tableView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 16),
                    tableView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -16),
                    tableView.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -16)
                ])
            }

            @objc private func flipCard() {
                let fromView = isFlipped ? backView : frontView
                let toView = isFlipped ? frontView : backView

                UIView.transition(from: fromView, to: toView, duration: 0.6, options: [.transitionFlipFromLeft, .showHideTransitionViews]) { [weak self] _ in
                    self?.isFlipped.toggle()
                }
            }

            func numberOfSections(in tableView: UITableView) -> Int {
                return detailItems.count
            }

            func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return 1
            }

            func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as? DetailCell else {
                    return UITableViewCell()
                }

                let item = detailItems[indexPath.section]
                cell.configure(iconName: item.0, detail: item.1)

                return cell
            }

            func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                switch section {
                case 0:
                    return "Date"
                case 1:
                    return "Time"
                case 2:
                    return "Location"
                case 3:
                    return "Organizer"
                case 4:
                    return "Description"
                default:
                    return nil
                }
            }
        }

        class DetailCell: UITableViewCell {
            private let iconImageView = UIImageView()
            private let detailLabel = UILabel()

            override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
                super.init(style: style, reuseIdentifier: reuseIdentifier)
                setupViews()
            }

            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }

            private func setupViews() {
                backgroundColor = .clear

                iconImageView.tintColor = .white
                iconImageView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(iconImageView)

                detailLabel.font = UIFont.preferredFont(forTextStyle: .body)
                detailLabel.textColor = .label
                detailLabel.numberOfLines = 0
                detailLabel.translatesAutoresizingMaskIntoConstraints = false
                addSubview(detailLabel)

                NSLayoutConstraint.activate([
                    iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                    iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 24),
                    iconImageView.heightAnchor.constraint(equalToConstant: 24),

                    detailLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
                    detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                    detailLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                    detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
                ])
            }

            func configure(iconName: String, detail: String) {
                iconImageView.image = UIImage(systemName: iconName)
                detailLabel.text = detail
            }
        }
