//
//  CharacterItemMocks.swift
//  RickAndMortyCastAppTests
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

@testable import RickAndMortyCastApp
import Foundation

class MocksHelper {
    static func characterItemResponse(id: Int = 1, name: String = "") -> CharacterItemResponse {
        return CharacterItemResponse(
            id: id,
            name: name,
            species: "",
            gender: "",
            status: "",
            image: URL(string: "https://www.google.com")!,
            url: URL(string: "https://www.google.com")!,
            type: "",
            location: .init(name: ""),
            origin: .init(name: ""))
    }

    static func characterItemFromDTO(_ dto: CharacterItemResponse) -> CharacterItem {
        return CharacterItem(characterItemDTO: dto)
    }

    static func characterItemSingleValueArray() -> [CharacterItem] {
        return [MocksHelper.characterItemFromDTO(MocksHelper.characterItemResponse())]
    }

    static func characterItemFullPage() -> [CharacterItem] {
        let dtos = MocksHelper.characterItemFullPageDTO()
        return dtos.map {
            MocksHelper.characterItemFromDTO($0)
        }
    }

    static func characterItemFullPageDTO() -> [CharacterItemResponse] {
        let items = [
            MocksHelper.characterItemResponse(id: 1),
            MocksHelper.characterItemResponse(id: 2),
            MocksHelper.characterItemResponse(id: 3),
            MocksHelper.characterItemResponse(id: 4),
            MocksHelper.characterItemResponse(id: 5),
            MocksHelper.characterItemResponse(id: 6),
            MocksHelper.characterItemResponse(id: 7),
            MocksHelper.characterItemResponse(id: 8),
            MocksHelper.characterItemResponse(id: 9),
            MocksHelper.characterItemResponse(id: 10),
            MocksHelper.characterItemResponse(id: 11),
            MocksHelper.characterItemResponse(id: 12),
            MocksHelper.characterItemResponse(id: 13),
            MocksHelper.characterItemResponse(id: 14),
            MocksHelper.characterItemResponse(id: 15),
            MocksHelper.characterItemResponse(id: 16),
            MocksHelper.characterItemResponse(id: 17),
            MocksHelper.characterItemResponse(id: 18),
            MocksHelper.characterItemResponse(id: 19),
            MocksHelper.characterItemResponse(id: 20)
        ]
        return items
    }
}
