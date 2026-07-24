import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date
    let updatedAt: Date
    let width: Int
    let height: Int
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}
