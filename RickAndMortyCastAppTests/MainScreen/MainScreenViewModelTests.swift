//
//  MainScreenViewModelTests.swift
//  Tests iOS
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

import Combine
import XCTest
@testable import RickAndMortyCastApp

class MainScreenViewModelTests: XCTestCase {

    @MainActor func test_initialStateLoad() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemFullPage() // sending a full page leaves fullList in false, so the next page is loaded

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)

        await sut.load()
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 1)
        XCTAssertEqual(sut.characters.count, 20)
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.fullList, false)
        XCTAssertEqual(charactersServiceMock.fetchCharactersPageWasCalled, true)
    }

    @MainActor func test_SecondRemoteFetchFullListLoad() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemSingleValueArray()

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        sut.currentPage = 2
        sut.characters = MocksHelper.characterItemSingleValueArray()
        persistenceControllerMock.downloadedPages = 1

        await sut.load()
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 2)
        XCTAssertEqual(sut.characters.count, 2)
        XCTAssertEqual(sut.currentPage, 3)
        XCTAssertEqual(sut.fullList, true)
        XCTAssertEqual(charactersServiceMock.fetchCharactersPageWasCalled, true)
    }

    @MainActor func test_LocalFetchFirstLoad() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemSingleValueArray()

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)

        persistenceControllerMock.downloadedPages = 2
        sut.currentPage = 1

        await sut.load()
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 2)
        XCTAssertEqual(sut.characters.count, 1)
        XCTAssertEqual(sut.currentPage, 3) // downloadedPages + 1
        XCTAssertEqual(sut.fullList, nil)
        XCTAssertEqual(charactersServiceMock.fetchCharactersWasCalled, true)
    }

    @MainActor func test_loadWithRefresh() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemFullPage() // sending a full page leaves fullList in false, so the next page is loaded

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        persistenceControllerMock.downloadedPages = 2
        sut.currentPage = 3

        await sut.load(isRefresh: true)
        XCTAssertEqual(persistenceControllerMock.clearWasCalled, true)
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 1)
        XCTAssertEqual(sut.characters.count, 20)
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.fullList, false)
        XCTAssertEqual(charactersServiceMock.fetchCharactersPageWasCalled, true)
    }

    @MainActor func test_ReloadLocal() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemFullPage() // sending a full page leaves fullList in false, so the next page is loaded

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        persistenceControllerMock.downloadedPages = 3
        sut.currentPage = 4

        sut.reload()
        await sut.load() // should be called after the state update by the view
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 3)
        XCTAssertEqual(sut.characters.count, 20)
        XCTAssertEqual(sut.currentPage, 4)
        XCTAssertEqual(sut.fullList, nil)
        XCTAssertEqual(charactersServiceMock.fetchCharactersWasCalled, true)
    }

    @MainActor func test_ReloadRemote() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()
        charactersServiceMock.returnValue = MocksHelper.characterItemFullPage() // sending a full page leaves fullList in false, so the next page is loaded

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        persistenceControllerMock.downloadedPages = 0
        sut.currentPage = 1

        sut.reload()
        await sut.load() // should be called after the state update by the view
        XCTAssertEqual(persistenceControllerMock.downloadedPages, 1)
        XCTAssertEqual(sut.characters.count, 20)
        XCTAssertEqual(sut.currentPage, 2)
        XCTAssertEqual(sut.fullList, false)
        XCTAssertEqual(charactersServiceMock.fetchCharactersPageWasCalled, true)
    }

    @MainActor func test_loadInternalError() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        persistenceControllerMock.downloadedPages = 0
        sut.currentPage = 1
        charactersServiceMock.error = CharactersServiceError.CouldNotFetchFromCoreData

        await sut.load()
        if case .failed(let error) = sut.state {
            XCTAssertEqual(error.internalError as? CharactersServiceError, CharactersServiceError.CouldNotFetchFromCoreData)
        }
    }

    @MainActor func test_loadUnknownError() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)
        persistenceControllerMock.downloadedPages = 0
        sut.currentPage = 1
        charactersServiceMock.error = NSError()

        await sut.load()
        if case .failed(let error) = sut.state {
            XCTAssertEqual(error.internalError as? UnknownError, UnknownError.default)
        }
    }

    @MainActor func test_applyFilter() async {
        let persistenceControllerMock = PersistenceControllerMock()
        let charactersServiceMock = CharacterServiceMock()

        let sut = MainScreenViewModel(
            charactersService: charactersServiceMock,
            persistenceController: persistenceControllerMock)

        sut.characters = MocksHelper.characterItemFullPage().map { character -> CharacterItem in
            if character.identifier == 2 {
                character.name = "Query"
                return character
            } else {
                return character
            }
        }

        XCTAssertEqual(sut.filteredCharacters.count, 20)
        sut.searchQuery = "Query"
        sut.applyFilter()
        XCTAssertEqual(sut.filteredCharacters.count, 1)
    }
}
