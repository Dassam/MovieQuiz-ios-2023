//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Dassam on 18.04.2023.
//

import UIKit

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
}

extension GameRecord: Comparable {
    static func < (lhs: GameRecord, rhs: GameRecord) -> Bool {
        return lhs.correct < rhs.correct 
    }
}
