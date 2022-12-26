//
//  MainScreenViewModel.swift
//  RickAndMortyCastApp
//
//  Created by Felipe Ferrari [EXT] on 23/12/22.
//

import Combine
import Foundation

class MainScreenViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed(RickAndMortyCastAppError)
        case loaded
    }

    var fullList: Bool?
    var currentPage = 1
    let perPage = 20

    var characters: [CharacterItem] = [] {
        didSet {
            applyFilter()
        }
    }

    @Published var filteredCharacters: [CharacterItem] = []
    @Published var searchQuery: String = ""
    @Published private(set) var state = State.idle
    
    private let service: CharactersServiceProtocol
    private var persistenceController: PersistenceControllerProtocol

    init(
        charactersService: CharactersServiceProtocol = CharactersService(),
        persistenceController: PersistenceControllerProtocol = PersistenceController.shared
    ) {
        self.service = charactersService
        self.persistenceController = persistenceController
    }

    @MainActor
    func load(isRefresh: Bool = false) async {
        if isRefresh {
            currentPage = 1
            persistenceController.clearDatabase()
            persistenceController.downloadedPages = 0
        }
        if currentPage == 1 {
            state = .loading
        }
        do {
            if currentPage == 1 {
                state = .loaded // If I set loaded state on every load, it scrolls the view to the top
            }

            if currentPage <= persistenceController.downloadedPages {
                currentPage = persistenceController.downloadedPages
                let newCharacters = try await service.fetchCharacters()
                characters = newCharacters
            } else {
                let newCharacters = try await service.fetchCharacters(page: currentPage)
                characters = characters + newCharacters
                if newCharacters.count < perPage {
                    fullList = true
                } else {
                    fullList = false
                }
                persistenceController.downloadedPages = currentPage
            }
            currentPage += 1
        } catch(let error) {
            if let internalError = error as? InternalError {
                state = .failed(RickAndMortyCastAppError(internalError: internalError))
            } else {
                state = .failed(RickAndMortyCastAppError(internalError: UnknownError.default))
            }
        }
    }

    func applyFilter() {
        filteredCharacters = characters.filter {
            guard let name = $0.name else { return false }
            guard !searchQuery.isEmpty else { return true }
            return name.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    func reload() {
        currentPage = 1
        state = .idle
    }
}


