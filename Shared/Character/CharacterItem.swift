//
//  CharacterItem.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 26/12/22.
//

import CoreData

class CharacterItem: NSManagedObject {
    struct Location: Decodable {
        let name: String
    }

    convenience init(characterItemDTO: CharacterItemResponse) {
        let persistentContainer = PersistenceController.shared.container
        guard
            let entity = NSEntityDescription.entity(
            forEntityName: "CharacterItem",
            in: persistentContainer.viewContext
        ) else { fatalError() }
        self.init(entity: entity, insertInto: persistentContainer.viewContext)
        self.identifier = Int64(characterItemDTO.id)
        self.name = characterItemDTO.name
        self.image = characterItemDTO.image
        self.url = characterItemDTO.url
        self.species = characterItemDTO.species
        self.type = characterItemDTO.type
        self.status = characterItemDTO.status
        self.gender = characterItemDTO.gender
        self.lastLocation = characterItemDTO.location.name
        self.origin = characterItemDTO.origin.name
    }

    func update(item: CharacterItemResponse) {
        self.name = item.name
        self.gender = item.gender
        self.status = item.status
        self.species = item.species
        self.image = item.image
        self.url = item.url
        self.type = item.type
        self.origin = item.origin.name
        self.lastLocation = item.location.name
    }
}
