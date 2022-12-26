//
//  CharacterItemDetailView.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 27/12/22.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: CharacterItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                footer
            }
        }
        .navigationTitle(character.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }

    var footer: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Origin: \(character.origin ?? "Unknown")").font(.title3)
            Text("Last known location: \(character.lastLocation ?? "None")").font(.title3)
        }.padding()
    }

    var header: some View {
        ZStack {
            AsyncImage(url: character.image) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fill)
                case .failure:
                    Image("Splash")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                @unknown default:
                    EmptyView()
                }
            }

            statusBadge
        }
    }

    var statusBadge: some View {
        HStack {
            Spacer()

            VStack {
                Spacer()

                HStack(spacing: 0) {
                    Circle()
                        .fill(character.status == "Alive" ? Color.green : Color.red)// Character statuses could be mapped to a struct, and stored as relationships on the database, this would be helpful to avoid comparing against raw values. In this case I think its overengineering 
                        .frame(width: 10, height: 10, alignment: .center)
                        .padding(6)

                    (Text(character.status ?? "Unknown status") + Text(" - ") + Text(character.species ?? "Unknown species")).foregroundColor(.white)
                    .padding(6)
                }.background {
                    Color.black.opacity(0.6)
                }
                .cornerRadius(6)
            }.padding()
        }
    }
}
