//
//  CharacterService.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 26/12/22.
//

import Foundation

protocol CharactersServiceProtocol {
    func fetchCharacters(page: Int) async throws -> [CharacterItem]
    func fetchCharacters() async throws -> [CharacterItem]
}

enum CharactersServiceError: InternalError {
    case CouldNotFetchFromCoreData

    var description: String {
        switch self {
        case .CouldNotFetchFromCoreData: return "There was an error fetching Characters from Core Data"
        }
    }
}

struct CharactersService: CharactersServiceProtocol {
    let charactersEndpoint: CharactersEndpointProtocol
    let persistenceController: PersistenceControllerProtocol

    init(
        charactersEndpoint: CharactersEndpointProtocol = CharactersEndpoint(),
        persistenceController: PersistenceControllerProtocol = PersistenceController.shared
    ) {
        self.charactersEndpoint = charactersEndpoint
        self.persistenceController = persistenceController
    }
    
    func fetchCharacters(page: Int) async throws -> [CharacterItem] {
        let characters = try await charactersEndpoint.fetchCharacters(page: page)
        var charactersToReturn: [CharacterItem] = []
        for character in characters {
            if let characterItem = try await update(item: character) {
                charactersToReturn.append(characterItem)
            }
        }

        try persistenceController.save()
        return charactersToReturn.compactMap { $0 }
    }

    @MainActor
    func fetchCharacters() async throws -> [CharacterItem] {
        do {
            return try persistenceController.fetch(id: nil, keyPath: nil)
        } catch {
            throw CharactersServiceError.CouldNotFetchFromCoreData
        }
    }

    @MainActor
    private func update(item: CharacterItemResponse) throws -> CharacterItem? {
        let characterId = item.id
        var currentCharacter: CharacterItem?
        let results: [CharacterItem]
        do {
            results = try persistenceController.fetch(
                id: Int(characterId),
                keyPath: #keyPath(CharacterItem.identifier)
            )
        } catch {
            throw CharactersServiceError.CouldNotFetchFromCoreData
        }

        if !results.isEmpty {
            currentCharacter = results.first
        } else {
            currentCharacter = CharacterItem(characterItemDTO: item)
        }
        
        currentCharacter?.update(item: item)
        return currentCharacter
    }
}
