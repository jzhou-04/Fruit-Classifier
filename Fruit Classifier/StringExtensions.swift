//
//  StringExtensions.swift
//  Fruit Classifier
//
//  Created by Jeffrey Zhou on 8/16/22.
//

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
