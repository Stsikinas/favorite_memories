//
//  WebServiceError.swift
//  Favorite Memories
//
//  Created by Epsilon User on 16/3/21.
//

import Foundation

enum WebServiceError: Error {
    case requestError(description: String)
    case responseCodeError(errorCode: Int)
    case dataParseError
    case genericError
    case timeout
    case connectionRefused
}
