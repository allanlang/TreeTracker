import Foundation
import GRDB

struct RemoteTree: Codable, FetchableRecord, PersistableRecord, TableRecord {
    let id: Int
    let supervisor: String
    let species: String
    let notes: String?
    var coordinates: String?
    var imageUrl: String?
    let imageMd5: String?
    var createDate: Date?
    var uploadDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case supervisor
        case species
        case notes
        case coordinates
        case imageUrl
        case imageMd5
        case createDate
        case uploadDate
    }
}
