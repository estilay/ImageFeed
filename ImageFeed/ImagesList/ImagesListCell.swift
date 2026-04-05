import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIndetifier = "ImagesListCell"
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    
}

