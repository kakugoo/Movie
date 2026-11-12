
import SwiftUI
import SwiftData

struct GenreListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Genre.name)
    private var genres: [Genre]

    var body: some View {
        List {
            if genres.isEmpty {
                ContentUnavailableView(
                    "Жанров пока нет",
                    systemImage: "square.stack",
                    description: Text("Создайте жанр при добавлении фильма")
                )
            } else {
                ForEach(genres) { genre in
                    HStack {
                        Text(genre.name)

                        Spacer()

                        Text("\(genre.movies.count) фильмов")
                            .foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: deleteGenres)
            }
        }
        .navigationTitle("Жанры")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Готово") {
                    dismiss()
                }
            }
        }
    }

    private func deleteGenres(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(genres[index])
        }
    }
}
