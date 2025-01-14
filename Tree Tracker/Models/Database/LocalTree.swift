import Foundation
import GRDB

struct LocalTree: Codable, FetchableRecord, PersistableRecord, TableRecord {
    let phImageId: String
    var createDate: Date?
    var supervisor: String
    var species: String
    var site: String
    var what3words: String?
    var notes: String?
    var coordinates: String?
    var imageMd5: String?

    // Because these are not accessible when synthesized by Swift, please do not remove it
    enum CodingKeys: String, CodingKey {
        case phImageId
        case createDate
        case supervisor
        case species
        case site
        case what3words
        case notes
        case coordinates
        case imageMd5
    }

    func toAirtableTree(imageUrl: String) -> AirtableTreeEncodable {
        return AirtableTreeEncodable(supervisor: supervisor, species: species, site: site, notes: notes, coordinates: coordinates, what3words: what3words, imageUrl: imageUrl, imageMd5: imageMd5, uploadDate: Date(), createDate: createDate)
    }
    
    func toAirtableTree(id: Int, imageUrl: String) -> AirtableTree {
        return AirtableTree(id: id, supervisor: supervisor, species: species, site: site, notes: notes, coordinates: coordinates, what3words: what3words, imageUrl: imageUrl, thumbnailUrl: imageUrl, imageMd5: imageMd5, uploadDate: .now, createDate: .now)
    }
}
