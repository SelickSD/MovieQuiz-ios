//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {

    // MARK: - Public Properties
    weak var delegate: QuestionFactoryDelegate?

    // MARK: - Private Properties
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    private var questions: [QuizQuestion] = []

    // MARK: - Initializers
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    // MARK: - Public methods
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    guard !mostPopularMovies.items.isEmpty else {
                        self.delegate?.didFailToLoadData(with: NetworkError.codeError)
                        return
                    }
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didFailToLoadData(with: NetworkError.loadImageError)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
