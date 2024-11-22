import Foundation

struct RecipeModel: Codable {
    let name: String
    let tags: [String]
    let ingredients: [String]
    let steps: [String]
}
