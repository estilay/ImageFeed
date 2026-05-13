import Foundation

// MARK: - OAuth2Service
final class OAuth2Service {
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let decoder = JSONDecoder()
    
    private init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - FetchToken
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("OAuthService: Invalid request - failed to create URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("OAuthService: Sending token request with code: \(code)")
        let task = urlSession.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.decodeToken(data: data, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
                
                self.task = nil
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - OAuthTokenRequest
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Failure to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let authTokenUrl = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        print("OAuth2Service: Token request URL: \(authTokenUrl)")
        print("OAuth2Service: Redirect URI: \(Constants.redirectURI)")
        
        return request
    }
    
    // MARK: - Decoding
    private func decodeToken(
        data: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            
            OAuth2TokenStorage.shared.token = tokenResponse.accessToken
            
            print("OAuthService: Token successfully received")
            completion(.success(tokenResponse.accessToken))
            
        } catch {
            print("OAuthService: Decoding error: \(error.localizedDescription)")
            completion(.failure(NetworkError.decodingError(error)))
        }
    }
}
