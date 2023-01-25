//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (UIAlertAction) -> Void
}


