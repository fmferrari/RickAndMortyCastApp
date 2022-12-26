//
//  ContentView.swift
//  Shared
//
//  Created by Felipe Ferrari [EXT] on 23/12/22.
//

import Combine
import SwiftUI

struct MainScreen: View {
    @StateObject var viewModel = MainScreenViewModel()
    @State var showAlert = false
    
    var body: some View {
        NavigationView {
            switch viewModel.state {
            case .idle:
                Image("Splash")
                    .onAppear {
                        Task {
                            await viewModel.load() // Will load data from data base if available or download from the API if needed
                        }
                    }
            case .loading:
                ProgressView()
            case .failed(let error):
                buildList(error: error)
            case .loaded:
                buildList()
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search by name...")
        .onChange(of: viewModel.searchQuery) { _ in
            viewModel.applyFilter()
        }
        .onSubmit(of: .search) {
            viewModel.applyFilter()
        }
    }

    func buildList(error: RickAndMortyCastAppError? = nil) -> some View {
        return List {
            ForEach(viewModel.filteredCharacters) { character in
                NavigationLink {
                    CharacterDetailView(character: character)
                } label: {
                    CharacterItemListView(character: character)
                }
            }

            if viewModel.fullList == false { // If the list is not yet full, we show the progress view
                HStack(alignment: .center) {
                    Spacer()

                    ProgressView()
                        .onAppear {
                            Task {
                                await viewModel.load() // Will fetch next page if necessary
                            }
                        }
                    
                    Spacer()
                }

            }
        }
        .refreshable {
            await viewModel.load(isRefresh: true) // Will redownload each page again in order to update the content
        }
        .onAppear {
            if error != nil {
                showAlert = true
            }
        }
        .alert(
            error?.description ?? UnknownError.default.description,
            isPresented: $showAlert) {
                Button("Retry", role: .none) {
                    showAlert = false
                    viewModel.reload() // Will go to initial state
                }
            }
        .navigationTitle("Rick & Morty Cast")
    }
}
