import Foundation

struct Recipe: Identifiable, Codable {
    var id: Int
    var name: String
    var tags: [String]
    var ingredients: [String]
    var steps:[String]
}
