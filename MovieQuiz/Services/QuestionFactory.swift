//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dassam on 12.04.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    
    private let moviesLoader: MoviesLoadingProtocol
    private weak var delegate: QuestionFactoryDelegate?

    init(moviesLoader: MoviesLoadingProtocol, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) 
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                    return
                }
            }
            
            let rating : Float = Float(movie.rating) ?? 0
            let ratingInQuestionFloat = generateRandomRange(rating)
            
            let text : String = "Рейтинг этого фильма \n больше чем \(ratingInQuestionFloat)?"
            let correctAnswer : Bool = rating >= ratingInQuestionFloat
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    private func generateRandomRange(_ rating: Float ) -> Float {
        let range : Int = 5
        let ratingInDoubleDigits : Int = Int(rating * 10)
        let minValue : Int = ratingInDoubleDigits - range
        let maxValue : Int = ratingInDoubleDigits + range
        let randomNumber : Int = min((minValue...maxValue).randomElement() ?? 0, 99)
        
        return Float(randomNumber) / 10
    }
}
