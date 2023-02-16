//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 16.02.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func setButtonsEnabled(_ isEnabled: Bool)
    func showAnswerResult(isCorrect: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
    func setupImage()
    func showAlert(alertModel: AlertModel?)
} 
