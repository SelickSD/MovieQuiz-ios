//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}


