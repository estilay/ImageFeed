import UIKit
import ProgressHUD

final class UIBlockingProgressHud {
    private static var window: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap{ $0 as? UIWindowScene }
            .first?.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
