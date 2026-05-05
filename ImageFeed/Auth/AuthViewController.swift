import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

// MARK: - AuthViewController
final class AuthViewController: UIViewController {
    // MARK: - Properties
    private let oauth2Service = OAuth2Service.shared
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    weak var delegate: AuthViewControllerDelegate?
    
    private lazy var unsplashLogoView: UIImageView = {
        let unsplashLogoImage = UIImage(named: "Logo_of_Unsplash")
        let unsplashLogoView = UIImageView(image: unsplashLogoImage)
        unsplashLogoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(unsplashLogoView)
        
        return unsplashLogoView
    }()
    
    private lazy var loginButton: UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        loginButton.tintColor = .ypBlack
        loginButton.backgroundColor = .ypWhite
        loginButton.addTarget(self, action: #selector(didLoginButtonTapped), for: .touchUpInside)
        loginButton.layer.cornerRadius = 16
        loginButton.layer.masksToBounds = true
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        return loginButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Actions
    @objc
    private func didLoginButtonTapped() {
        performSegue(withIdentifier: showWebViewSegueIdentifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                print("Failed to prepare \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - UI Methods
    private func setupUI() {
        view.backgroundColor = .ypBlack
        configureBackButton()
        setupConstraints()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        setupUnsplashLogoViewConstraints()
        setupLoginButtonConstraints()
    }
    
    private func setupUnsplashLogoViewConstraints() {
        NSLayoutConstraint.activate([
            unsplashLogoView.widthAnchor.constraint(equalToConstant: 60),
            unsplashLogoView.heightAnchor.constraint(equalToConstant: 60),
            unsplashLogoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogoView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupLoginButtonConstraints() {
        NSLayoutConstraint.activate([
            loginButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
}

// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        OAuth2Service.shared.fetchOAuthToken(code) { result in
            switch result {
            case .success(let token):
                self.delegate?.didAuthenticate(self)
                print("Token received: \(token)")
                vc.dismiss(animated: true)
                
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                vc.dismiss(animated: true)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
