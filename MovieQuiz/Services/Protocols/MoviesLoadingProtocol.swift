//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Dassam on 28.04.2023.
//

import UIKit

protocol MoviesLoadingProtocol {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

