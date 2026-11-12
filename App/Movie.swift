
import Foundation
import SwiftData

@Model
final class Movie {
    var title: String
    var year: Int
    var genre: Genre?
    var isWatched: Bool
    var isFavorite: Bool = false
    var rating: Int
    var createdAt: Date

    init(
        title: String,
        year: Int,
        genre: Genre? = nil,
        isWatched: Bool = false,
        isFavorite: Bool = false,
        rating: Int = 0,
        createdAt: Date = .now
    ) {
        self.title = title
        self.year = year
        self.genre = genre
        self.isWatched = isWatched
        self.isFavorite = isFavorite
        self.rating = rating
        self.createdAt = createdAt
    }
}
