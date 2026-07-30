import UIKit
import Kingfisher

// MARK: - ImagesListViewControllerProtocol
protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func updateTableViewAnimated(with indexPaths: [IndexPath], isInsert: Bool)
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool)
    func showLikeErrorAlert()
    func showLoadingIndicator()
    func hideLoadingIndicator()
}

// MARK: - ImagesListViewController
final  class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    // MARK: - Properties
    var presenter: ImagesListPresenterProtocol?
    @IBOutlet weak private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var photos: [Photo] {
        presenter?.photos ?? []
    }
    
    // MARK: - Configure
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                print("[ImagesListViewController]: Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - ImagesListViewController Protocol Methods
    func updateTableViewAnimated(with indexPaths: [IndexPath], isInsert: Bool) {
        tableView.performBatchUpdates {
            if isInsert {
                tableView.insertRows(at: indexPaths, with: .automatic)
            } else {
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
        } completion: { _ in }
    }
    
    func updateCellLikeStatus(at indexPath: IndexPath, isLiked: Bool) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            return
        }
        cell.setIsLiked(isLiked)
    }
    
    func showLoadingIndicator() {
        UIBlockingProgressHud.show()
    }
    
    func hideLoadingIndicator() {
        UIBlockingProgressHud.dismiss()
    }
    
    func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось изменить статус лайка. Попробуйте еще раз",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    // MARK: - Cell Configuration
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        cell.delegate = self
        
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
        cell.setIsLiked(photo.isLiked)
        
        // Date config
        cell.dateLabel.text = photo.createdAt?.formattedDate ?? nil
    }
}

// MARK: - ImagesListCellDelegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("[ImagesListViewController]: Could not get indexPath for cell")
            return
        }
        
        presenter?.didTapLike(at: indexPath)
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            print("[ImagesListViewController] Error casting cell to type ImagesListCell")
            return UITableViewCell()
        }
        
        configCell(for: cell, with: indexPath)
        return cell
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
        presenter?.willDisplayCell(at: indexPath)
    }
}
