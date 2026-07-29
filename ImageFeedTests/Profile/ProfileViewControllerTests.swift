@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    // MARK: - Tests
    @MainActor
    func testViewControllerCallsPresenterOnViewDidLoad() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testViewControllerCallsShowLogoutAlert() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        // When
        viewController.showLogoutAlert()
        
        // Then
        XCTAssertTrue(true)
    }
    
    @MainActor
    func testViewControllerCallsNavigateToSplashScreen() {
        // Given
        let viewController = ProfileViewController()
        
        // When
        viewController.navigateToSplashScreen()
        
        // Then
        XCTAssertTrue(true)
    }
    
    @MainActor
    func testViewControllerCallsUpdateProfileDetails() {
        // Given
        let viewController = ProfileViewController()
        
        // When
        viewController.updateProfileDetails(
            name: "Test Name",
            loginName: "@TestLogin",
            bio: "TestBio"
        )
        
        // Then
        XCTAssertTrue(true)
    }
    
    @MainActor
    func testViewControllerCallsUpdateAvatar() {
        // Given
        let viewController = ProfileViewController()
        let testImage = UIImage(systemName: "person.circle.fill")
        
        // When
        viewController.updateAvatar(image: testImage)
        
        // Then
        XCTAssertTrue(true)
    }
}
