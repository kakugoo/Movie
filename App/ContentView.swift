
import SwiftUI
import SwiftData

enum MovieStatusFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case unwatched = "Не просмотрено"
    case watched = "Просмотрено"

    var id: String { rawValue }
}

enum MovieSortOption: String, CaseIterable, Identifiable {
    case date = "По дате добавления"
    case title = "По названию"
    case year = "По году"
    case rating = "По рейтингу"

    var id: String { rawValue }

    var descriptors: [SortDescriptor<Movie>] {
        switch self {
        case .date:
            return [
                SortDescriptor(
                    \Movie.createdAt,
                    order: .reverse
                )
            ]

        case .title:
            return [
                SortDescriptor(\Movie.title)
            ]

        case .year:
            return [
                SortDescriptor(
                    \Movie.year,
                    order: .reverse
                )
            ]

        case .rating:
            return [
                SortDescriptor(
                    \Movie.rating,
                    order: .reverse
                )
            ]
        }
    }
}

struct ContentView: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query private var allMovies: [Movie]

    @State private var searchText = ""
    @State private var selectedFilter: MovieStatusFilter = .all
    @State private var selectedSort: MovieSortOption = .date

    @State private var onlyFavorites = false

    @State private var showingAddMovie = false
    @State private var showingGenres = false

    @State private var isSelecting = false

    @State private var selectedIDs: Set<PersistentIdentifier> = []

    @State private var showingDeleteConfirmation = false

    private var watchedCount: Int {
        allMovies.filter { $0.isWatched }.count
    }

    private var averageRating: Double {
        let ratedMovies = allMovies.filter { $0.rating > 0 }

        guard !ratedMovies.isEmpty else {
            return 0
        }

        let sum = ratedMovies.reduce(0) {
            $0 + $1.rating
        }

        return Double(sum) / Double(ratedMovies.count)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    statisticView(
                        title: "Всего",
                        value: "\(allMovies.count)"
                    )

                    Spacer()

                    statisticView(
                        title: "Просмотрено",
                        value: "\(watchedCount)"
                    )

                    Spacer()

                    statisticView(
                        title: "Средняя оценка",
                        value: String(
                            format: "%.1f",
                            averageRating
                        )
                    )
                }
                .padding(.horizontal)
                .padding(.top, 8)
                Picker(
                    "Статус",
                    selection: $selectedFilter
                ) {
                    ForEach(MovieStatusFilter.allCases) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                Toggle(isOn: $onlyFavorites) {
                    Label(
                        "Только избранное",
                        systemImage: "star.fill"
                    )
                }
                .padding(.horizontal)
                FilteredMovieList(
                    searchText: searchText,
                    filter: selectedFilter,
                    sortOption: selectedSort,
                    onlyFavorites: onlyFavorites,
                    hasMovies: !allMovies.isEmpty,
                    isSelecting: isSelecting,
                    selectedIDs: $selectedIDs
                )
            }
            .navigationTitle("Фильмы")
            .searchable(
                text: $searchText,
                prompt: "Название или жанр"
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Picker(
                            "Сортировка",
                            selection: $selectedSort
                        ) {
                            ForEach(MovieSortOption.allCases) { option in
                                Text(option.rawValue)
                                    .tag(option)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingGenres = true
                    } label: {
                        Image(systemName: "square.stack.3d.up")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        isSelecting ? "Готово" : "Выбрать"
                    ) {
                        isSelecting.toggle()
                        selectedIDs.removeAll()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if !isSelecting {
                        Button {
                            showingAddMovie = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if isSelecting {
                    HStack {
                        Text("Выбрано: \(selectedIDs.count)")

                        Spacer()

                        Button(
                            "Удалить",
                            role: .destructive
                        ) {
                            showingDeleteConfirmation = true
                        }
                        .disabled(selectedIDs.isEmpty)
                    }
                    .padding()
                    .background(.regularMaterial)
                }
            }
            .confirmationDialog(
                "Удалить выбранные фильмы?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(
                    "Удалить \(selectedIDs.count)",
                    role: .destructive
                ) {
                    deleteSelectedMovies()
                }
            }
            .sheet(isPresented: $showingAddMovie) {
                AddMovieView()
            }
            .sheet(isPresented: $showingGenres) {
                NavigationStack {
                    GenreListView()
                }
            }
            .onChange(of: searchText) { _, _ in
                selectedIDs.removeAll()
            }

            .onChange(of: selectedFilter) { _, _ in
                selectedIDs.removeAll()
            }

            .onChange(of: onlyFavorites) { _, _ in
                selectedIDs.removeAll()
            }
        }
    }

    private func statisticView(
        title: String,
        value: String
    ) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func deleteSelectedMovies() {
        for movie in allMovies {
            if selectedIDs.contains(movie.persistentModelID) {
                modelContext.delete(movie)
            }
        }

        selectedIDs.removeAll()
        isSelecting = false
    }
}


struct FilteredMovieList: View {

    @Environment(\.modelContext)
    private var modelContext

    @Query private var movies: [Movie]

    let hasMovies: Bool
    let isSelecting: Bool

    @Binding var selectedIDs: Set<PersistentIdentifier>

    init(
        searchText: String,
        filter: MovieStatusFilter,
        sortOption: MovieSortOption,
        onlyFavorites: Bool,
        hasMovies: Bool,
        isSelecting: Bool,
        selectedIDs: Binding<Set<PersistentIdentifier>>
    ) {
        self.hasMovies = hasMovies
        self.isSelecting = isSelecting
        self._selectedIDs = selectedIDs

        let search = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let onlyWatched = filter == .watched
        let onlyUnwatched = filter == .unwatched
        let predicate = #Predicate<Movie> { movie in
            (
                search.isEmpty ||
                movie.title.localizedStandardContains(search) ||
                (
                    movie.genre?.name.localizedStandardContains(search)
                    == true
                )
            )
            &&
            (!onlyWatched || movie.isWatched)
            &&
            (!onlyUnwatched || !movie.isWatched)
            &&
            (!onlyFavorites || movie.isFavorite)
        }

        _movies = Query(
            filter: predicate,
            sort: sortOption.descriptors
        )
    }

    var body: some View {
        List {
            if movies.isEmpty {

                ContentUnavailableView(
                    hasMovies
                    ? "Ничего не найдено"
                    : "Фильмов пока нет",
                    systemImage: hasMovies
                    ? "magnifyingglass"
                    : "film",
                    description: Text(
                        hasMovies
                        ? "Измените поиск или фильтр"
                        : "Добавьте первый фильм"
                    )
                )

            } else {

                ForEach(movies) { movie in

                    if isSelecting {
                        Button {
                            toggleSelection(movie)
                        } label: {

                            HStack(spacing: 12) {

                                Image(
                                    systemName: selectedIDs.contains(
                                        movie.persistentModelID
                                    )
                                    ? "checkmark.circle.fill"
                                    : "circle"
                                )
                                .foregroundStyle(
                                    selectedIDs.contains(
                                        movie.persistentModelID
                                    )
                                    ? Color.accentColor
                                    : Color.secondary
                                )

                                VStack(
                                    alignment: .leading,
                                    spacing: 4
                                ) {
                                    Text(movie.title)
                                        .font(.headline)

                                    Text(
                                        "\(movie.genre?.name ?? "Без жанра"), \(movie.year)"
                                    )
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if movie.isFavorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                    } else {
                        NavigationLink {
                            MovieDetailView(movie: movie)
                        } label: {
                            MovieRow(movie: movie)
                        }
                    }
                }
                .onDelete(perform: deleteMovies)
            }
        }
    }


    private func toggleSelection(_ movie: Movie) {
        let id = movie.persistentModelID

        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func deleteMovies(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(movies[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(moviePreviewContainer)
}
