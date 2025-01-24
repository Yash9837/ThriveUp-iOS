import UIKit

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private var onboardingPages: [OnboardingViewController] = []
    private let pageControl = UIPageControl()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Previous", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .orange
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true // Initially hidden on the first page
        return button
    }()
    
    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex
            let isLastPage = currentIndex == onboardingPages.count - 1
            nextButton.setTitle(isLastPage ? "Get Started" : "Next", for: .normal)
            previousButton.isHidden = currentIndex == 0 // Hide previous button on the first page
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOnboardingPages()
        setupPageControl()
        setupNextButton()
        setupPreviousButton()
        setupSkipButton()
        setupPageViewController()
    }
    
    private func setupOnboardingPages() {
        onboardingPages = [
            OnboardingViewController(imageName: "onboarding_event_post", titleText: "Post Events", descriptionText: "Easily create and share your events with the community."),
            OnboardingViewController(imageName: "onboarding_event_register", titleText: "Register for Events", descriptionText: "Secure your spot for exciting events with one tap."),
            OnboardingViewController(imageName: "onboarding_updates", titleText: "Stay Updated", descriptionText: "Get real-time updates and announcements for your favorite events."),
            OnboardingViewController(imageName: "onboarding_swipe", titleText: "Bookmark Events", descriptionText: "Swipe right to save events to your favorites.")
        ]
    }
    
    private func setupPageViewController() {
        dataSource = self
        delegate = self
        if let firstPage = onboardingPages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = onboardingPages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .orange
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupNextButton() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupPreviousButton() {
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        view.addSubview(previousButton)
        
        NSLayoutConstraint.activate([
            previousButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            previousButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            previousButton.widthAnchor.constraint(equalToConstant: 100),
            previousButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupSkipButton() {
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    @objc private func nextButtonTapped() {
        if currentIndex < onboardingPages.count - 1 {
            currentIndex += 1
            setViewControllers([onboardingPages[currentIndex]], direction: .forward, animated: true, completion: nil)
        } else {
            transitionToMainApp()
        }
    }
    
    @objc private func previousButtonTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            setViewControllers([onboardingPages[currentIndex]], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    @objc private func skipButtonTapped() {
        transitionToMainApp()
    }

    private func transitionToMainApp() {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.rootViewController = GeneralTabbarController()
        UIView.transition(with: window!, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
    
    // MARK: - PageViewController DataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingPages.firstIndex(of: viewController as! OnboardingViewController), index > 0 else { return nil }
        return onboardingPages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = onboardingPages.firstIndex(of: viewController as! OnboardingViewController), index < onboardingPages.count - 1 else { return nil }
        return onboardingPages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let visibleViewController = viewControllers?.first as? OnboardingViewController {
            currentIndex = onboardingPages.firstIndex(of: visibleViewController) ?? 0
        }
    }
}
