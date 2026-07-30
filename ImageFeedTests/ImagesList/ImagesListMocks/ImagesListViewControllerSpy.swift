@testable import ImageFeed
import XCTest

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    var showLoadingIndicatorCalled = false
    var hideLoadingIndicatorCalled = false
    
    func updateTableViewAnimated(with indexPaths: [IndexPath], isInsert: Bool) {}
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool) {}
    func showLikeErrorAlert() {}
    
    func showLoadingIndicator() {
        showLoadingIndicatorCalled = true
    }
    
    func hideLoadingIndicator() {
        hideLoadingIndicatorCalled = true
    }
}
