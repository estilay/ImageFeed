import Foundation

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    // MARK: - Properties
    private let tokenKey = "bearerToken"
    private let dataStorage = UserDefaults.standard
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        
        set {
            if let token = newValue {
                dataStorage.set(token, forKey: tokenKey)
            } else {
                dataStorage.removeObject(forKey: tokenKey)
            }
        }
    }
}
