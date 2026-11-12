
import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Bindable var movie: Movie

    var body: some View {
        Form {
            Section("Фильм") {
                TextField("Название", text: $movie.title)

                Stepper(
                    "Год: \(movie.year)",
                    value: $movie.year,
                    in: 1888...2100
                )
            }

            Section("Жанр") {
                GenrePicker(selectedGenre: $movie.genre)
            }

            Section("Статус") {
                Toggle("Просмотрено", isOn: $movie.isWatched)

                Toggle("В избранном", isOn: $movie.isFavorite)

                Stepper(
                    "Оценка: \(movie.rating)",
                    value: $movie.rating,
                    in: 0...5
                )
            }
        }
        .navigationTitle("Редактирование")
        .navigationBarTitleDisplayMode(.inline)
    }
}
