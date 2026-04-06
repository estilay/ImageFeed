import UIKit

final class ImagesListBottomGradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    private var firstColor = UIColor(hex: "#1A1B22", alpha: 0.0)
    private var secondColor = UIColor(hex: "#1A1B22", alpha: 1.0)
    
    private enum Point {
        case top
        case bottom
        
        var point: CGPoint {
            switch self {
            case .top:
                return CGPoint(x: 0.5, y: 0)
            case .bottom:
                return CGPoint(x: 0.5, y: 1.0)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    private func setupGradient() {
        self.layer.addSublayer(gradientLayer)
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.startPoint = Point.top.point
        gradientLayer.endPoint = Point.bottom.point
    }
}
