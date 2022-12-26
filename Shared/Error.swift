//
//  Error.swift
//  RickAndMortyCastApp (iOS)
//
//  Created by Felipe Ferrari [EXT] on 29/12/22.
//

protocol InternalError: Error {
    var description: String { get }
}

struct RickAndMortyCastAppError: Error {
    let internalError: InternalError

    var description: String { return internalError.description }
}

enum UnknownError: InternalError {
    case `default`

    var description: String {
        switch self {
        case .default: return "An unexpected error ocurred"
        }
    }
}
