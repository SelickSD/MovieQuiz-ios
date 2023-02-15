//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 15.02.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {

    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 1
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var statistic: StatisticService?

    init(viewController: MovieQuizViewController) {
        self.viewController = viewController

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        statistic = StatisticServiceImplementation()
    }

    // MARK: - QuestionFactoryDelegate

        func didLoadDataFromServer() {
            viewController?.hideLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }

        func didFailToLoadData(with error: Error) {
            let message = error.localizedDescription
            showNetworkError(message: message)
        }

        func didRecieveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }

            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 1
        correctAnswers = 0
    }

    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }

    func increaseCorrectAnswers() {
        correctAnswers += 1
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }

    func noButtonClicked() {
        didAnswer(isYes: false)
    }

    func yesButtonClicked() {
        didAnswer(isYes: true)
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        guard let viewController = viewController else { return }

        viewController.showLoadingIndicator()
        viewController.setButtonsEnabled(false)
        viewController.showAnswerResult(isCorrect: isYes == currentQuestion.correctAnswer)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        guard let viewController = viewController else { return }
        viewController.hideLoadingIndicator()
        viewController.setButtonsEnabled(true)
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    func showNextQuestionOrResults() {
        guard let viewController = viewController else { return }
        guard let statistic = statistic else { return }
        viewController.setupImage()

        if isLastQuestion() {
            statistic.store(correct: correctAnswers, total: questionsAmount)

            let model = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statistic.gamesCount)
                Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", arguments: [statistic.totalAccuracy]))%
                """,
                buttonText: "Сыграть еще раз?",
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.resetQuestionIndex()
                    self.questionFactory?.requestNextQuestion()
                })
            viewController.alertPresenter?.showAlert(alertModel: model)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }

    func showNetworkError(message: String) {

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.resetQuestionIndex()
                self.questionFactory?.loadData()
            })
        viewController?.alertPresenter?.showAlert(alertModel: model)
    }
    func showImageLoaderError(message: String) {
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") {_ in
            self.questionFactory?.loadData()
        }
        viewController?.alertPresenter?.showAlert(alertModel: model)
    }
}