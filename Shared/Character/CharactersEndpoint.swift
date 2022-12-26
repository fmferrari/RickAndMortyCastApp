//
//  CharactersEndpoint.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 26/12/22.
//
import Foundation

struct Result: Decodable {
    let results: [CharacterItemResponse]
}

struct CharacterItemResponse: Decodable {
    let id: Int
    let name: String
    let species: String
    let gender: String
    let status: String
    let image: URL
    let url: URL
    let type: String
    let location: CharacterItem.Location
    let origin: CharacterItem.Location
}

protocol CharactersEndpointProtocol {
    func fetchCharacters(page: Int) async throws -> [CharacterItemResponse]
}

enum RickAndMortyEndpointError: InternalError {
    case couldNotFetch
    case couldNotDecode

    var description: String {
        switch self {
        case .couldNotFetch: return "Something went wrong fetching data from Rick and Morty API"
        case .couldNotDecode: return "There was an error decoding the data from Rick and Morty API"
        }
    }
}

struct CharactersEndpoint: CharactersEndpointProtocol {
    let urlSession = URLSession.shared
    let jsonDecoder = JSONDecoder()

    func fetchCharacters(page: Int) async throws -> [CharacterItemResponse] {
        let url = URL(string: "https://rickandmortyapi.com/api/character?page=\(page.description)")! // In a scenario where we need multiple endpoints from the same API, this should be abstracted into domain and endpoints. For simplicity I will leave this hardcoded.
        do {
            let (data, _) = try await urlSession.data(from: url)
            return try jsonDecoder.decode(Result.self, from: data).results
        } catch(let error) {
            if error is DecodingError {
                throw RickAndMortyEndpointError.couldNotDecode
            } else {
                throw RickAndMortyEndpointError.couldNotFetch
            }
        }
    }
}

