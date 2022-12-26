//
//  CharactersServiceTests.swift
//  RickAndMortyCastAppTests
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

import XCTest
@testable import RickAndMortyCastApp

class CharactersServiceTests: XCTestCase {

    @MainActor
    func test_fetchCharactersPageSuccessEmptyDB() async throws {
        let persistenceControllerMock = PersistenceControllerMock.shared
        let charactersEndpointMock = CharactersEndpointMock()
        charactersEndpointMock.returnValue = MocksHelper.characterItemFullPageDTO()
        let randomElement = charactersEndpointMock.returnValue.randomElement()
        charactersEndpointMock.returnValue = charactersEndpointMock.returnValue.map { character -> CharacterItemResponse in
            if let randomElement = randomElement, character.id == randomElement.id {
                return MocksHelper.characterItemResponse(id: character.id, name: "Modified")
            } else {
                return character
            }
        }
        persistenceControllerMock.reset()
        persistenceControllerMock.returnValue = MocksHelper.characterItemFullPage()

        let sut = CharactersService(
            charactersEndpoint: charactersEndpointMock,
            persistenceController: persistenceControllerMock)

        let characters = try await sut.fetchCharacters(page: 1)
        XCTAssertEqual(persistenceControllerMock.saveWasCalled, true)
        XCTAssertEqual(characters.count, 20)
        characters.forEach { character in
            guard let randomElement = randomElement else { return XCTFail() }
            if character.identifier == Int64(randomElement.id) {
                XCTAssertEqual(character.name, "Modified")
            } else {
                XCTAssertEqual(character.name, "")
            }
        }
        XCTAssertEqual(persistenceControllerMock.fetchWasCalled, true)
    }

    @MainActor
    func test_fetchCharactersSuccess() async throws {
        let persistenceControllerMock = PersistenceControllerMock.shared
        persistenceControllerMock.reset()
        persistenceControllerMock.returnValue = MocksHelper.characterItemFullPage()
        let charactersEndpointMock = CharactersEndpointMock()

        let sut = CharactersService(
            charactersEndpoint: charactersEndpointMock,
            persistenceController: persistenceControllerMock)

        let characters = try await sut.fetchCharacters()

        XCTAssertEqual(persistenceControllerMock.saveWasCalled, false)
        XCTAssertEqual(characters.count, 20)
        XCTAssertEqual(persistenceControllerMock.fetchWasCalled, true)
    }

    @MainActor
    func test_fetchCharactersFailure() async throws {
        let persistenceControllerMock = PersistenceControllerMock.shared
        persistenceControllerMock.reset()
        persistenceControllerMock.returnValue = MocksHelper.characterItemFullPage()
        persistenceControllerMock.error = PersistenceError.couldNotFetchFromCoreData
        let charactersEndpointMock = CharactersEndpointMock()

        let sut = CharactersService(
            charactersEndpoint: charactersEndpointMock,
            persistenceController: persistenceControllerMock)

        do {
            _ = try await sut.fetchCharacters()
        } catch(let error) {
            XCTAssertEqual(error as? CharactersServiceError, CharactersServiceError.CouldNotFetchFromCoreData)
        }
    }

    @MainActor
    func test_fetchCharactersPageEndpointFailure() async throws {
        let persistenceControllerMock = PersistenceControllerMock.shared
        persistenceControllerMock.reset()
        persistenceControllerMock.returnValue = MocksHelper.characterItemFullPage()
        persistenceControllerMock.error = PersistenceError.couldNotFetchFromCoreData
        let charactersEndpointMock = CharactersEndpointMock()
        charactersEndpointMock.error = RickAndMortyEndpointError.couldNotFetch
        let sut = CharactersService(
            charactersEndpoint: charactersEndpointMock,
            persistenceController: persistenceControllerMock)

        do {
            _ = try await sut.fetchCharacters(page: 1)
        } catch(let error) {
            XCTAssertEqual(error as? RickAndMortyEndpointError, RickAndMortyEndpointError.couldNotFetch)
        }
    }

    @MainActor
    func test_fetchCharactersPageFetchFailure() async throws {
        let persistenceControllerMock = PersistenceControllerMock.shared
        persistenceControllerMock.reset()
        persistenceControllerMock.returnValue = MocksHelper.characterItemFullPage()
        persistenceControllerMock.error = PersistenceError.couldNotFetchFromCoreData
        let charactersEndpointMock = CharactersEndpointMock()
        charactersEndpointMock.returnValue = MocksHelper.characterItemFullPageDTO()
        let sut = CharactersService(
            charactersEndpoint: charactersEndpointMock,
            persistenceController: persistenceControllerMock)

        do {
            _ = try await sut.fetchCharacters(page: 1)
        } catch(let error) {
            XCTAssertEqual(error as? CharactersServiceError, CharactersServiceError.CouldNotFetchFromCoreData)
        }
    }
}
