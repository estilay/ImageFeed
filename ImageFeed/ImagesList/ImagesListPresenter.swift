import UIKit

// MARK: - ImagesListPresenterProtocol
protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

// MARK: - ImagesListPresenter
final class ImagesListPresenter: ImagesListPresenterProtocol {
    // MARK: - Properties
    weak var view: ImagesListViewControllerProtocol?
    private var observer: NSObjectProtocol?
    private let imagesListService = ImagesListService.shared
    private(set) var photos: [Photo] = []
    
    // MARK: - Test Helpers
    func setPhotosForTesting(_ photos: [Photo]) {
        self.photos = photos
    }
    
    // MARK: - Lifecycle
    func viewDidLoad() {
        setupNotificationObserver()
        fetchPhotosNextPage()
    }
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("[ImagesListPresenter]: Loading next page (row: \(indexPath.row), total: \(photos.count))")
            fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let newLikeStatus = !photo.isLiked
        print("[ImagesListPresenter]: \(newLikeStatus ? "Liking" : "Unliking") photo \(photo.id)")
        
        view?.showLoadingIndicator()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newLikeStatus) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view?.hideLoadingIndicator()
                switch result {
                case .success:
                    self.photos = self.imagesListService.photos
                    self.view?.updateCellLikeStatus(at: indexPath, isLiked: self.photos[indexPath.row].isLiked)
                    
                case .failure(let error):
                    print("[ImagesListPresenter]: Failed to change like status: \(error.localizedDescription)")
                    
                    // Reject changes for Like Status
                    self.view?.showLikeErrorAlert()
                    self.view?.updateCellLikeStatus(at: indexPath, isLiked: photo.isLiked)
                }
            }
        }
    }
    
    // MARK: - Update TableViewAnimated
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            var indexPaths: [IndexPath] = []
            var isInsert = true
            
            if oldCount < newCount {
                indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                isInsert = true
            } else if oldCount > newCount {
                indexPaths = (newCount..<oldCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                isInsert = false
            }
            
            view?.updateTableViewAnimated(with: indexPaths, isInsert: isInsert)
        }
    }
    
    // MARK: - Setup Notification Observer
    private func setupNotificationObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }
    
    // MARK: - Deinit
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
