@testable import ImageFeed
import XCTest

final class ProfilePresenterTests: XCTestCase {
    
    func testViewDidLoadCallsLoadProfile() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertTrue(view.updateProfileDetailsCalled)
    }
    
    func testDidTapLogoutButtonShowsLogoutAlert() {
        // Given
        let view = ProfileViewControllerSpy()
        let presenter = ProfileViewPresenter()
        presenter.view = view
        
        // When
        presenter.didTapLogoutButton()
        
        // Then
        XCTAssertTrue(view.showLogoutAlertCalled)
    }
    
    func testConfirmLogoutNavigatesToSplashScreen() {
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
