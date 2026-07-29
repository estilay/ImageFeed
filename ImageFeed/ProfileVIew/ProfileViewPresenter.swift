import UIKit
import Kingfisher

// MARK: - ProfileViewPresenterProtocol
public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func confirmLogout()
    func loadAvatar()
}


// MARK: - ProfileViewPresenter
final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        loadProfile()
        setupAvatarObserver()
        loadAvatar()
        
    }
    
    // MARK: - Public Methods
    func loadProfile() {
        guard let profile = profileService.profile else {
            view?.updateProfileDetails(name: "Имя не указано", loginName: "@неизвестный_пользователь", bio: "Профиль не заполнен")
            return
        }
        
        view?.updateProfileDetails(name: profile.name, loginName: profile.loginName, bio: profile.bio ?? "Профиль не заполнен")
        
    }
    
    func didTapLogoutButton() {
        view?.showLogoutAlert()
    }
    
    func confirmLogout() {
        ProfileLogoutService.shared.profileLogout()
        self.view?.navigateToSplashScreen()
           
    }
    
    func loadAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let imageUrl = URL(string: profileImageURL)
        else { return }
        
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.white, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        
        KingfisherManager.shared.retrieveImage(
            with: imageUrl,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]
        ) { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    self?.view?.updateAvatar(image: value.image)
                case .failure(let error):
                    print(error)
                    self?.view?.updateAvatar(image: placeholderImage)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupAvatarObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                
                self.loadAvatar()
            }
        
    }
    
    private func removeAvatarObserver() {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
            profileImageServiceObserver = nil
        }
    }
    
    // MARK: - Deinit
    deinit {
        removeAvatarObserver()
    }
}
