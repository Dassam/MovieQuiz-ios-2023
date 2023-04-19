//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Dassam on 19.04.2023.
//

import UIKit

protocol StatisticServiceProtocol {
    var bestGame: GameRecord { get }
    var gamesCount: Int { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
