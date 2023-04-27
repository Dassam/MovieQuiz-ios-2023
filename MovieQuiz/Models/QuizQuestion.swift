//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Dassam on 12.04.2023.
//

import UIKit

/*
 _____OLD MODEL_____
 struct QuizQuestion {
    let image: String // строка с названием фильма
    let text: String // строка с вопросом о рейтинге фильма
    let correctAnswer: Bool // правильный ответ на вопрос
}// модель каждого вопрса
*/

struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
}
