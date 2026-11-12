
import SwiftUI
import SwiftData

struct GenrePicker: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Genre.name)
    private var genres: [Genre]

    @Binding var selectedGenre: Genre?

    @State private var newGenreName = ""

    var body: some View {
        Picker("Жанр", selection: $selectedGenre) {
            Text("Без жанра")
                .tag(nil as Genre?)

            ForEach(genres) { genre in
                Text(genre.name)
                    .tag(genre as Genre?)
            }
        }

        HStack {
            TextField("Новый жанр", text: $newGenreName)

            Button("Создать") {
                createGenre()
            }
            .disabled(cleanName.isEmpty)
        }
    }

    private var cleanName: String {
        newGenreName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func createGenre() {
        guard !cleanName.isEmpty else { return }

        if let existing = genres.first(where: {
            $0.name.localizedCaseInsensitiveCompare(cleanName)
                == .orderedSame
        }) {
            selectedGenre = existing
        } else {
            let genre = Genre(name: cleanName)
            modelContext.insert(genre)
            selectedGenre = genre
        }

        newGenreName = ""
    }
}
