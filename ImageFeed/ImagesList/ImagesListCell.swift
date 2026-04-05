import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIndetifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
}
