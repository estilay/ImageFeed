@testable import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var didTapLogoutButtonCalled = false
    var confirmLogoutCalled = false
    var loadAvatarCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didTapLogoutButton() {
        didTapLogoutButtonCalled = true
    }
    
    func confirmLogout() {
        confirmLogoutCalled = true
    }
    
    func loadAvatar() {
        loadAvatarCalled = true
    }
}
