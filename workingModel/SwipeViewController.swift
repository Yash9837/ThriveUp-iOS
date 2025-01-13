//
//  SwipeViewController.swift
//  ThriveUp
//
//  Created by palak seth on 17/11/24.
//
//
//  SwipeViewController.swift
//  ThriveUp
//
//  Created by palak seth on 17/11/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class SwipeViewController: UIViewController {
    
    private var eventStack: [EventModel] = []
    private var bookmarkedEvents: [EventModel] = []
    private let db = Firestore.firestore()
    
    private let cardContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let discardButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📖", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Swipe Events"
        
        setupViews()
        setupConstraints()
        fetchEventsFromDatabase()
    }
    
    private func setupViews() {
        view.addSubview(cardContainerView)
        view.addSubview(discardButton)
        view.addSubview(bookmarkButton)
        
        discardButton.addTarget(self, action: #selector(handleDiscard), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            cardContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            cardContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            discardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            discardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            discardButton.widthAnchor.constraint(equalToConstant: 70),
            discardButton.heightAnchor.constraint(equalToConstant: 70),
            
            bookmarkButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            bookmarkButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 70),
            bookmarkButton.heightAnchor.constraint(equalToConstant: 70),
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
                cardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: CGFloat(index) * 8),
                cardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -CGFloat(index) * 8),
                cardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: CGFloat(index) * 8),
                cardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -CGFloat(index) * 8)
            ])
        }
    }
    
    private func createCard(for event: EventModel) -> UIView {
        let cardView = FlippableCardView(event: event)
        cardView.translatesAutoresizingMaskIntoConstraints = false

        // Add swipe gesture recognizers
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        cardView.addGestureRecognizer(panGesture)
        
        return cardView
    }

    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        guard let cardView = gesture.view as? FlippableCardView else { return }
        let translation = gesture.translation(in: view)
        let xFromCenter = translation.x
        
        switch gesture.state {
        case .changed:
            // Move the card based on swipe gesture
            cardView.transform = CGAffineTransform(translationX: xFromCenter, y: 0)
                .rotated(by: xFromCenter / 200)
            cardView.alpha = 1 - abs(xFromCenter) / view.frame.width
        
        case .ended:
            if xFromCenter > 100 {
                // Swipe right: Bookmark event
                bookmarkEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: true)
                changeButtonColor(button: bookmarkButton, color: .green)
            } else if xFromCenter < -100 {
                // Swipe left: Discard event
                discardEvent(for: cardView.event)
                animateCardOffScreen(cardView, toRight: false)
                changeButtonColor(button: discardButton, color: .red)
            } else {
                // Reset card position if not swiped far enough
                UIView.animate(withDuration: 0.3) {
                    cardView.transform = .identity
                    cardView.alpha = 1
                }
            }
        default:
            break
        }
    }

    private func animateCardOffScreen(_ cardView: FlippableCardView, toRight: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            let direction: CGFloat = toRight ? 1 : -1
            cardView.transform = CGAffineTransform(translationX: direction * self.view.frame.width, y: 0)
            cardView.alpha = 0
        }) { _ in
            cardView.removeFromSuperview()
            self.displayTopCards() // Load the next card
        }
    }

    private func changeButtonColor(button: UIButton, color: UIColor) {
        UIView.animate(withDuration: 0.5) {
            button.backgroundColor = color
        } completion: { _ in
            UIView.animate(withDuration: 0.5) {
                button.backgroundColor = .orange // Reset to original color
            }
        }
    }

    @objc private func handleDiscard() {
        if let topEvent = eventStack.last {
            discardEvent(for: topEvent)
        }
    }

    @objc private func handleBookmark() {
        if let topEvent = eventStack.last {
            bookmarkEvent(for: topEvent)
        }
    }

    private func bookmarkEvent(for event: EventModel) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User is not authenticated")
            return
        }
        
        let eventData: [String: Any] = [
            "userId": userId,
            "eventId": event.eventId,
            "title": event.title,
            "category": event.category,
            "attendanceCount": event.attendanceCount,
            "organizerName": event.organizerName,
            "date": event.date,
            "time": event.time,
            "location": event.location,
            "locationDetails": event.locationDetails,
            "description": event.description ?? "No description available.",
            "timestamp": Timestamp()
        ]
        
        db.collection("swipedeventsdb").addDocument(data: eventData) { error in
            if let error = error {
                print("Error saving bookmarked event: \(error.localizedDescription)")
            }
        }
        
        eventStack.removeAll { $0.eventId == event.eventId }
        displayTopCards()
    }
    
    private func discardEvent(for event: EventModel) {
        eventStack.removeAll { $0.eventId == event.eventId }
        displayTopCards()
    }
}

// MARK: - Flippable Card View

class FlippableCardView: UIView {
    
    private var isFlipped = false
    private let frontView = UIView()
    private let backView = UIView()
    let event: EventModel
    
    init(event: EventModel) {
        self.event = event
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        frontView.backgroundColor = .white
        frontView.layer.cornerRadius = 10
        frontView.layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage(named: event.imageName))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        frontView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: frontView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: frontView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: frontView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: frontView.bottomAnchor)
        ])
        
        backView.backgroundColor = .white
        backView.layer.cornerRadius = 10
        backView.layer.masksToBounds = true
        
        let detailsLabel = UILabel()
        detailsLabel.numberOfLines = 0
        detailsLabel.textAlignment = .center
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.text = """
        Title: \(event.title)
        Category: \(event.category)
        Organizer: \(event.organizerName)
        Date: \(event.date)
        Time: \(event.time)
        Location: \(event.location)
        Attendance: \(event.attendanceCount)
        Description: \(event.description ?? "No description available.")
        """
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        backView.addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            detailsLabel.centerXAnchor.constraint(equalTo: backView.centerXAnchor),
            detailsLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor),
            detailsLabel.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 10),
            detailsLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -10)
        ])
        
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
    
    @objc private func flipCard() {
        isFlipped.toggle()
        
        let fromView = isFlipped ? frontView : backView
        let toView = isFlipped ? backView : frontView
        
        UIView.transition(from: fromView, to: toView, duration: 0.6, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
    }
}
