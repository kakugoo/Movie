
import SwiftUI
import SwiftData

@main
struct MovieCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Movie.self, Genre.self])
    }
}
