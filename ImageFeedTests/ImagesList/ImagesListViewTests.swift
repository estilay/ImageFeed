@testable import ImageFeed
import XCTest

final class ImagesListViewControllerTests: XCTestCase {
    // MARK: - Helper
    @MainActor
    private func makeViewController() -> ImagesListViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("Could not instantiate ImagesListViewController from Main.storyboard")
        }
        return viewController
    }
    
    // MARK: - Tests
    @MainActor
    func testViewDidLoadCallsPresenterViewDidLoad() {
        // Given
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        _ = viewController.view
        
        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    @MainActor
    func testFetchPhotosNextPageCallsPresenterFetchPhotosNextPage() {
        // Given
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        
        // When
        viewController.presenter?.fetchPhotosNextPage()
        
        // Then
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    @MainActor
    func testWillDisplayCellCallsPresenterWillDisplayCell() {
        // Given
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        viewController.presenter?.willDisplayCell(at: indexPath)
        
        // Then
        XCTAssertTrue(presenter.willDisplayCellCalled)
    }
    
    @MainActor
    func testDidTapLikeCallsPresenterDidTapLike() {
        // Given
        let viewController = makeViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)
        let indexPath = IndexPath(row: 0, section: 0)
        
        // When
        viewController.presenter?.didTapLike(at: indexPath)
        
        // Then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
}
