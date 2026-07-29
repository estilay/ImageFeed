import UIKit

// MARK: - ProfileViewControllerProtocol
public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func updateProfileDetails(name: String, loginName: String, bio: String)
    func updateAvatar(image: UIImage?)
    func showLogoutAlert()
    func navigateToSplashScreen()
}

// MARK: - ProfileViewController
final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    // MARK: - UI Elements
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImage(resource: .stubAvatar)
        let profileImageView = UIImageView(image: profileImage)
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        return profileImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = .ypWhite
        nameLabel.text = "Имя не указано"
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        return nameLabel
    }()
    
    private lazy var loginNameLabel: UILabel = {
        let loginNameLabel = UILabel()
        loginNameLabel.textColor = .ypGray
        loginNameLabel.text = "@неизвестный_пользователь"
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        
        return loginNameLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.text = "Профиль не заполнен"
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        return descriptionLabel
    }()
    
    private lazy var logoutButton: UIButton = {
        let logoutButton: UIButton
        if let logoutButtonImage = UIImage(named: "logout_button") {
            logoutButton = UIButton.systemButton(
                with: logoutButtonImage,
                target: self,
                action: #selector(self.didTapLogoutButton)
            )
        } else {
            logoutButton = UIButton(type: .system)
            logoutButton.setTitle("Exit", for: .normal)
            logoutButton.setTitleColor(.ypRed, for: .normal)
            logoutButton.addTarget(self, action: #selector(self.didTapLogoutButton), for: .touchUpInside)
        }
        
        logoutButton.accessibilityIdentifier = "logoutButton"
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        return logoutButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Actions
    @objc
    private func didTapLogoutButton() {
        presenter?.didTapLogoutButton()
    }
    
    // MARK: - Logout Alert
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выйти",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = "LogoutAlert"
        
        let confirmAction = UIAlertAction(
            title: "Да",
            style: .default
        ) { [weak self] _ in
            self?.presenter?.confirmLogout()
        }
        
        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .default
        )
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation
    func navigateToSplashScreen() {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        guard let window else {
            assertionFailure("[ProfileViewController]: Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        
        window.rootViewController = splashViewController
    }
    
    // MARK: - Profile update methods
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = loginName
        descriptionLabel.text = bio
    }
    
    func updateAvatar(image: UIImage?) {
        profileImageView.image = image ?? UIImage(resource: .stubAvatar)
    }
}

// MARK: - UI Setup
extension ProfileViewController {
    //  Setup UI method
    private func setupUI() {
        view.backgroundColor = .ypBlack
        setupConstraints()
    }
    // MARK: - Setup Constraints
    private func setupConstraints() {
        createProfileImageviewConstraints()
        createNameLabelConstraints()
        createLoginNameLabelConstraints()
        createDescriptionLabelConstraints()
        createLogoutButtonConstraints()
    }
    
    private func createProfileImageviewConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
    }
    
    private func createNameLabelConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func createLoginNameLabelConstraints() {
        NSLayoutConstraint.activate([
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createDescriptionLabelConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func createLogoutButtonConstraints() {
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
