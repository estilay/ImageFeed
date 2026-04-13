import UIKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }
    
// MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .ypBlack
        
        // MARK:  Add Profile Image View
        let profileImage = UIImage(named: "avatar_photo")
        let profileImageView = UIImageView(image: profileImage)
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        // MARK:  Add Labels
        let nameLabel = UILabel()
        let loginNameLabel = UILabel()
        let descriptionLabel = UILabel()
        
        nameLabel.textColor = .ypWhite
        loginNameLabel.textColor = .ypGray
        descriptionLabel.textColor = .ypWhite
        
        nameLabel.text = "Екатерина Новикова"
        loginNameLabel.text = "@ekaterina_nov"
        descriptionLabel.text = "Hello, world"
        
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descriptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor)
        ])
        
        // MARK: Add Logout Button
        let logoutButtonImage = UIImage(named: "logout_button")
        guard let logoutButtonImage else { return }
        let logoutButton = UIButton.systemButton(
            with: logoutButtonImage,
            target: self,
            action: #selector(self.didTapLogoutButton)
        )
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        logoutButton.tintColor = .ypRed
        
        NSLayoutConstraint.activate([
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc
    private func didTapLogoutButton() {
        
    }
    
}
