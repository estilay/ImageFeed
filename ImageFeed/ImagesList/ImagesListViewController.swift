import UIKit
import Kingfisher

final  class ImagesListViewController: UIViewController {
    @IBOutlet weak private var tableView: UITableView!
    
    private let imagesListService = ImagesListService()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] = []

    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNotificationObserver()
        
        // Loading first page
        imagesListService.fetchPhotosNextPage()
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
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
    // MARK: - Prepare ShowSingleImage Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                print("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                if oldCount < newCount {
                    let indexPaths = (oldCount..<newCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    tableView.insertRows(at: indexPaths, with: .automatic)
                } else if oldCount > newCount {
                    let indexPaths = (newCount..<oldCount).map { i in
                        IndexPath(row: i, section: 0)
                    }
                    tableView.deleteRows(at: indexPaths, with: .automatic)
                }
            } completion: { _ in }
        }
    }
    // MARK: - SetupTableView
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Cell Configuration
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        // Image config
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.indicatorType = .activity
            
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: UIImage(resource: .stub),
                options: [
                    .cacheOriginalImage
                ]
            ) { [weak self] result in
                
                switch result {
                case .success:
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                    
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            cell.cellImage.image = UIImage(resource: .stub)
        }

        // Like config
        let isLiked = indexPath.row % 2 == 0
        let likeImage = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        cell.likeButton.setImage(likeImage, for: .normal)
        // Date config
        cell.dateLabel.text = photo.createdAt?.formattedDate ?? "Unknown date"
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            print("Error casting cell to type ImagesListCell")
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let photo = photos[indexPath.row]
        let imageSize = photo.size
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - (imageInsets.left + imageInsets.right)
        let scale = imageViewWidth / imageSize.width
        let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            print("Loading next page (row: \(indexPath.row), total: \(photos.count))")
            imagesListService.fetchPhotosNextPage()
        }
    }
}
