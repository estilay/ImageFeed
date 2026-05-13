import Foundation

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    init() {}
    
    // MARK: - Properties
    private let tokenKey = "bearerToken"
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
