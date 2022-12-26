//
//  CharacterServiceMock.swift
//  Tests iOS
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

@testable import RickAndMortyCastApp

class CharacterServiceMock: CharactersServiceProtocol {
    var fetchCharactersPageWasCalled: Bool = false
    var fetchCharactersWasCalled: Bool = false
    var error: Error?
    var returnValue: [CharacterItem] = []

    func fetchCharacters(page: Int) async throws -> [CharacterItem] {
        fetchCharactersPageWasCalled = true
        if let error = error {
            throw error
        }
        return returnValue
    }

    func fetchCharacters() async throws -> [CharacterItem] {
        fetchCharactersWasCalled = true
        if let error = error {
            throw error
        }
        return returnValue
    }

}
