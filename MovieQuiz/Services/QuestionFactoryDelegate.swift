//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dassam on 15.04.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
