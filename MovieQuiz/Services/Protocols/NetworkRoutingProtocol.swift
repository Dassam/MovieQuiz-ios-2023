//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Dassam on 08.05.2023.
//

import UIKit

protocol NetworkRoutingProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
