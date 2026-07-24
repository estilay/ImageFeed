import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    // MARK: - Singleton
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    // MARK: - Properties
    private let tokenKey = "token"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    
    func clearToken() {
            token = nil
            print("[OAuth2TokenStorage]: Token cleared")
        }
}
