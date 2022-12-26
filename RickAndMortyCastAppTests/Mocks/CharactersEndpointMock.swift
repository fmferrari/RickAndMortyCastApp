//
//  CharactersEndpointMock.swift
//  RickAndMortyCastAppTests
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

@testable import RickAndMortyCastApp

class CharactersEndpointMock: CharactersEndpointProtocol {
    var fetchCharactersPageWasCalled: Bool = false
    var error: Error?
    var returnValue: [CharacterItemResponse] = []

    func fetchCharacters(page: Int) async throws -> [CharacterItemResponse] {
        fetchCharactersPageWasCalled = true
        if let error = error {
            throw error
        }
        return returnValue
    }
}
