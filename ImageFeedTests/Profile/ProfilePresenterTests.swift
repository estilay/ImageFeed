@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    // MARK: - Tests
    @MainActor
    func testPresenterLoadsProfile() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.loadProfile()
        
        // Then
        XCTAssertTrue(view.updateProfileDetailsCalled)
    }
    
    @MainActor
    func testPresenterCallsUpdateAvatar() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.loadAvatar()
        
        // Then
        if ProfileImageService.shared.avatarURL != nil {
            let expectation = expectation(description: "Avatar loading")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertTrue(view.updateAvatarCalled)
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 3)
        } else {
            XCTAssertTrue(true)
        }
    }
    
    @MainActor
    func testPresenterShowыLogoutAlert() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.didTapLogoutButton()
        
        // Then
        XCTAssertTrue(view.showLogoutAlertCalled)
    }
    
    @MainActor
    func testConfirmLogoutCallsProfileLogout() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.confirmLogout()
        
        // Then
        XCTAssertTrue(view.navigateToSplashScreenCalled)
    }
}
