//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
