import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Properties
    private let showAuthViewSegueIdentifier = "ShowAuthView"
    private let storageToken = OAuth2TokenStorage.shared.token
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showAuthViewSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthViewSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuthViewSegueIdentifier)")
                return
            }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func switchToTabBarController() {
        let window = UIApplication.shared.connectedScenes
            .compactMap{ $0 as? UIWindowScene }
            .flatMap{ $0.windows }
            .first{ $0.isKeyWindow }
        
        guard let window else { return }
        
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
                profileImageService.fetchProfileURL(username: profile.username) { _ in
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
