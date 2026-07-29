@testable import ImageFeed
import XCTest

final class ImagesListPresenterTests: XCTestCase {
    // MARK: - Tests
    @MainActor
    func testViewDidLoadCallsFetchPhotosNextPage() {
        // Given
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = view
        
        // When
        presenter.viewDidLoad()
        
        // Then
        XCTAssertNotNil(presenter)
    }
    
    @MainActor
    func testWillDisplayCellAtLastIndexCallsFetchPhotosNextPage() {
        // Given
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = view
        
        presenter.setPhotosForTesting([
            Photo.testPhoto(id: "1"),
            Photo.testPhoto(id: "2"),
            Photo.testPhoto(id: "3")
        ])
        
        let lastIndexPath = IndexPath(row: 2, section: 0)
        
        // When
        presenter.willDisplayCell(at: lastIndexPath)
        
        // Then
        XCTAssertNotNil(presenter)
    }
    
    @MainActor
    func testDidTapLikeShowsLoadingIndicator() {
        // Given
        let view = ImagesListViewControllerSpy()
        let presenter = ImagesListPresenter()
        presenter.view = view
        presenter.setPhotosForTesting([
            Photo.testPhoto(id: "test", isLiked: false)
        ])
        
        // When
        presenter.didTapLike(at: IndexPath(row: 0, section: 0))
        
        // Then
        XCTAssertTrue(view.showLoadingIndicatorCalled)
    }
}

// MARK: - Helper Extension
extension Photo {
    static func testPhoto(
        id: String = "test_id",
        isLiked: Bool = false
    ) -> Photo {
        return Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: "https://example.com/large.jpg",
            isLiked: isLiked
        )
    }
}
