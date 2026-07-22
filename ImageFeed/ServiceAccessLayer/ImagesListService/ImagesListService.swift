import Foundation
import CoreGraphics

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let width: Int
    let height: Int
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}

struct UrlsResult: Codable {
    let full: String
    let thumb: String
}

struct LikeResponse: Codable {
    let photo: LikePhotoResponse
}

struct LikePhotoResponse: Codable {
    let id: String
    let likedByUser: Bool
}

// MARK: - ImagesListService
final class ImagesListService {
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var lastPageRequested: Int?
    private let pageSize = 10
    private var isFetching = false
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private var activeRequest: UUID?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    // MARK: - Fetching Photos
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        if let lastPageRequested = lastPageRequested,
           lastPageRequested == nextPage {
            return
        }
        
        if isFetching {
            print("[ImagesListService.fetchPhotosNextPage]: Request is already fetching")
            return
        }
        
        isFetching = true
        lastPageRequested = nextPage
        task?.cancel()
        
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(pageSize)") else {
            isFetching = false
            lastPageRequested = nil
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("[ImagesListService.fetchPhotosNextPage]: No token available - user not authorized")
            isFetching = false
            lastPageRequested = nil
            return
        }
        
        let requestID = UUID()
        activeRequest = requestID
        
        print("[ImagesListService.fetchPhotosNextPage]: Fetching page \(nextPage) with ID: \(requestID)")
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            guard requestID == self.activeRequest else {
                print("[ImagesListService.fetchPhotosNextPage]: Received response for old request ID: \(requestID)")
                return
            }
            
            DispatchQueue.main.async {
                self.isFetching = false
                self.task = nil
                self.activeRequest = nil
                self.lastPageRequested = nil
                
                switch result {
                case .success(let photoResult):
                    let newPhotos = photoResult.map { photoResult in
                        Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: photoResult.createdAt,
                            welcomeDescription: photoResult.description,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.full,
                            isLiked: photoResult.likedByUser
                        )
                    }
                    
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    
                case .failure(let error):
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        print("[ImagesListService.fetchPhotosNextPage]: Task was cancelled for request ID: \(requestID)")
                    } else {
                        print("[ImagesListService.fetchPhotosNextPage]: Error fetching photos: \(error.localizedDescription)")
                    }
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Change Like
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService.changeLike]: No token avaible - user not authorized")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[ImagesListService.changeLike]: Invalid URL")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let requestID = UUID()
        activeRequest = requestID
        
        print("[ImagesListService.changeLike]: \(isLike ? "Liking" : "Unliking") photo \(photoId) with request \(requestID)")
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<LikeResponse, Error>) in
            guard let self = self else { return }
            
            guard requestID  == self.activeRequest else {
                print("[ImagesListService.changeLike]: Ignoring old response for request ID: \(requestID)")
                return
            }
            
            DispatchQueue.main.async {
                self.activeRequest = nil
                self.task = nil
                
                switch result {
                case .success(let response):
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let oldPhoto = self.photos[index]
                        self.photos[index] = Photo(
                            id: oldPhoto.id,
                            size: oldPhoto.size,
                            createdAt: oldPhoto.createdAt,
                            welcomeDescription: oldPhoto.welcomeDescription,
                            thumbImageURL: oldPhoto.thumbImageURL,
                            largeImageURL: oldPhoto.largeImageURL,
                            isLiked: response.photo.likedByUser
                        )
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self
                        )
                        print("ImagesListService.changeLike]: Successfully \(isLike ? "liked" : "unliked") photo \(photoId)")
                    }
                    completion(.success(()))
                    
                case .failure(let error):
                    if let urlError = error as? URLError, urlError.code == .cancelled {
                        print("[ImagesListService.changeLike]: Task wa cancelled for request ID: \(requestID)")
                    } else {
                        print("[ImagesListService.changeLike]: Error changing like: \(error.localizedDescription)")
                    }
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
