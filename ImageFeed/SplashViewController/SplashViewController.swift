import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Properties
    private let storageToken = OAuth2TokenStorage.shared.token
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage.shared
    
    private lazy var splashImageView: UIImageView = {
        let splashImage = UIImage(resource: .splashScreenLogo)
        let splashImageView = UIImageView(image: splashImage)
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashImageView)
        
        return splashImageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    // MARK: - Methods
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("Invalid AuthViewController ID")
            return
        }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    
    private func switchToTabBarController() {
        let window = UIApplication.shared.connectedScenes
            .compactMap{ $0 as? UIWindowScene }
            .flatMap{ $0.windows }
            .first{ $0.isKeyWindow }
        
        guard let window else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHud.show()
        
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHud.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { _ in
                    }
                self.switchToTabBarController()
            case .failure(let error):
                print(error)
                break
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        
        switchToTabBarController()
    }
}

// MARK: - UI setup
extension SplashViewController {
    private func setupUI() {
        view.backgroundColor = .ypBlack
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
