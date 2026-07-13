import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}
// MARK: - OAuth2Service
final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let dataStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    
    private var task: URLSessionTask?
    private var lastCode: String?
    private var activeRequest: UUID?
    
    private(set) var authToken: String? {
        get {
            return dataStorage.token
        }
        set {
            dataStorage.token = newValue
        }
    }
    
    let decoder = JSONDecoder()
    
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
            print("[OAuth2Service]: Duplicate code detected. Current: \(lastCode ?? "nil"), New: \(code). Request rejected")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Invalid request - failed to create URLRequest")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        //  Generate unique ID for request
        let requestID = UUID()
        activeRequest = requestID
        lastCode = code
        
        print("[OAuth2Service]: Sending token request with code: \(code), ID: \(requestID)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            guard self.activeRequest == requestID else {
                print("[OAuth2Service]: Ignoring old response for request ID: \(requestID)")
                return
            }
            
            DispatchQueue.main.async {
                UIBlockingProgressHud.dismiss()
                
                self.task = nil
                self.lastCode = nil
                self.activeRequest = nil
                
                switch result {
                case .success(let body):
                    let authToken = body.accessToken
                    self.authToken = authToken
                    print("[OAuth2Service]: Token successfully received")
                    completion(.success(authToken))
                    
                case .failure(let error):
                    // Check, if task has been cancelled
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        print("[OAuth2Service]: Task was cancelled for request ID: \(requestID)")
                    } else {
                        print("[OAuth2Service]: FetchOAuthToken Error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - OAuthTokenRequest
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("[OAuth2Service.makeOAuthTokenRequest]: Failure to create URL")
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
        print("[OAuth2Service.makeOAuthTokenRequest]: Token request URL: \(authTokenUrl)")
        print("[OAuth2Service.makeOAuthTokenRequest]: Redirect URI: \(Constants.redirectURI)")
        
        return request
    }
}

// MARK: - Network Client

extension OAuth2Service {
    private func object(for request: URLRequest, completion: @escaping (Result<OAuthTokenResponseBody, Error>) -> Void) -> URLSessionTask {
        
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    print("[OAuth2Service.objectTask]: Token successfully received")
                    let body = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    completion(.success(body))
                }
                catch {
                    print("[OAuth2Service.objectTask]: Decoding error: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("[OAuth2Service.objectTask]: Failed to retrieve OAuth token: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}
