
import SwiftData

@MainActor
let moviePreviewContainer: ModelContainer = {
    let configuration = ModelConfiguration(
        isStoredInMemoryOnly: true
    )

    do {
        let container = try ModelContainer(
            for: Movie.self,
            Genre.self,
            configurations: configuration
        )

        let sciFi = Genre(name: "Фантастика")
        let animation = Genre(name: "Анимация")

        container.mainContext.insert(sciFi)
        container.mainContext.insert(animation)

        container.mainContext.insert(
            Movie(
                title: "Интерстеллар",
                year: 2014,
                genre: sciFi,
                isWatched: true,
                isFavorite: true,
                rating: 5
            )
        )

        container.mainContext.insert(
            Movie(
                title: "Начало",
                year: 2010,
                genre: sciFi,
                rating: 4
            )
        )

        container.mainContext.insert(
            Movie(
                title: "Унесённые призраками",
                year: 2001,
                genre: animation
            )
        )

        return container
    } catch {
        fatalError("Preview container error: \(error)")
    }
}()
