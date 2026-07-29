import UIKit
import Kingfisher

// MARK: - SingleImageViewController
final class SingleImageViewController: UIViewController {
    // MARK: - Properties
    var imageURL: String?
    
    var image: UIImage? {
        didSet {
            updateImageViewWithImage()
        }
    }
    
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var imageView: UIImageView!
    
    
    // MARK: -  Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        backwardButton.accessibilityIdentifier = "BackwardButton"
        
        loadImage()
        setupImageAndScrollView()
    }
    
    // MARK: - Actions
    
    @IBAction func didTapBackwardButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func didTapSharingButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        present(share, animated: true, completion: nil)
    }
    
    // MARK: - Load Image
    private func loadImage() {
        guard let urlString = imageURL,
              let fullImageUrl = URL(string: urlString) else {
            imageView.image = UIImage(resource: .stub)
            return
        }
        
        UIBlockingProgressHud.show()
        
        imageView.kf.setImage(
            with: fullImageUrl,
            placeholder: UIImage(resource: .stub),
            options: [
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            
            UIBlockingProgressHud.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let imageResult):
                self.image = imageResult.image
                self.setupImageAndScrollView()
                
            case .failure(let error):
                print("Failed to load image: \(error)")
                self.showError()
            }
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать еще раз?",
            preferredStyle: .alert
            )
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .default) { [weak self] _ in
            self?.imageView.image = UIImage(resource: .stub)
        }
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Private zoom methods
    private func setupImageAndScrollView() {
        guard let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func updateImageViewWithImage() {
        guard isViewLoaded, let image else { return }
        imageView.image = image
        imageView.frame.size = image.size
        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        
        guard imageSize.width > 0, imageSize.height > 0 else {
            print("Invalid image size \(imageSize)")
            return
        }
        
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func updateContentInsetForCentering() {
        guard let imageView else { return }
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let hInset = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let vInset = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(top: vInset, left: hInset, bottom: vInset, right: hInset)
    }
    
}

// MARK: - UIScrollViewDelegate
extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInsetForCentering()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentInsetForCentering()
    }
}

