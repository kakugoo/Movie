
import Foundation
import SwiftData

@Model
final class Genre {
    var name: String

    @Relationship(deleteRule: .nullify, inverse: \Movie.genre)
    var movies: [Movie] = []

    init(name: String) {
        self.name = name
    }
}
