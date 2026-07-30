@testable import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    var navigateToSplashScreenCalled = false
    
    var receivedName: String?
    var receivedLoginName: String?
    var receivedBio: String?
    var receivedAvatarImage: UIImage?
    
    func updateProfileDetails(name: String, loginName: String, bio: String) {
        updateProfileDetailsCalled = true
        receivedName = name
        receivedLoginName = loginName
        receivedBio = bio
    }
    
    func updateAvatar(image: UIImage?) {
        updateAvatarCalled = true
        receivedAvatarImage = image
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
    
    func navigateToSplashScreen() {
        navigateToSplashScreenCalled = true
    }
}
