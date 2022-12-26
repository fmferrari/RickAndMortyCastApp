//
//  CharacterItemListView.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 27/12/22.
//

import SwiftUI

struct CharacterItemListView: View {
    let character: CharacterItem

    var body: some View {
        HStack {
            AsyncImage(url: character.image)
                { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 60, maxHeight: 60)
                    case .failure:
                        Image("Splash")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 60, maxHeight: 60)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(6)
                .padding([.top, .bottom, .trailing], 6)

            Text(character.name ?? "Undefined Name")

            Spacer()

            Circle()
                .fill(character.status == "Alive" ? Color.green : Color.red) // Character statuses could be mapped to a struct, and stored as relationships on the database, this would be helpful to avoid comparing against raw values. In this case I think its overengineering 
                .frame(width: 10, height: 10, alignment: .center)
        }
    }
}
