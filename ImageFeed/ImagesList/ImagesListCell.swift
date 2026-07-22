import UIKit
import Kingfisher

// MARK: - Tap Like Delegate
protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        likeButton.addTarget(
            self,
            action: #selector(likeButtonTapped),
            for: .touchUpInside
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
    
    // MARK: - Actions
    @objc
    private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Public Methods
    func setIsLiked(_ isLiked: Bool) {
        let image = isLiked ? UIImage(resource: .likeButtonOn) : UIImage(resource: .likeButtonOff)
        likeButton.setImage(image, for: .normal)
    }
}
