import UIKit

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    private let profileService = ProfileService.shared
    private let token = OAuth2TokenStorage.shared.token
    
    // MARK: - UI Elements
    private lazy var profileImageView: UIImageView = {
        let profileImage = UIImage(resource: .avatarPhoto)
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
        
        logoutButton.tintColor = .ypRed
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        return logoutButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails()
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails() {
        if let profile = profileService.profile {
            nameLabel.text = profile.name
            loginNameLabel.text = profile.loginName
            descriptionLabel.text = profile.bio
        }
    }
    // MARK: - Actions
    // TODO:
    @objc
    private func didTapLogoutButton() {
        
    }
}


// MARK: - UI Setup
extension ProfileViewController {
    // MARK: - Setup UI method
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
