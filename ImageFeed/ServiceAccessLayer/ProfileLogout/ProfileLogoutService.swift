import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    // MARK: - Public Methods
    func profileLogout() {
        OAuth2TokenStorage.shared.clearToken()
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatar()
        ImagesListService.shared.clearPhotos()
        cleanCookies()
        print("[ProfileLogoutService]: Logout completed successfully")
    }
    
    // MARK: - Private Methods
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
