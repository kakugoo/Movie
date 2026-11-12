
import SwiftUI
import SwiftData

struct AddMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var year = Calendar.current.component(.year, from: .now)
    @State private var selectedGenre: Genre?

    var body: some View {
        NavigationStack {
            Form {
                Section("Информация о фильме") {
                    TextField("Название", text: $title)

                    Stepper(
                        "Год: \(year)",
                        value: $year,
                        in: 1888...2100
                    )
                }

                Section("Жанр") {
                    GenrePicker(selectedGenre: $selectedGenre)
                }
            }
            .navigationTitle("Новый фильм")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        saveMovie()
                    }
                    .disabled(
                        cleanTitle.isEmpty ||
                        selectedGenre == nil
                    )
                }
            }
        }
    }

    private var cleanTitle: String {
        title.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func saveMovie() {
        guard let selectedGenre else { return }

        let movie = Movie(
            title: cleanTitle,
            year: year,
            genre: selectedGenre
        )

        modelContext.insert(movie)
        dismiss()
    }
}
