//
//  ContentView.swift
//  Fruit Classifier
//
//  Created by Jeffrey Zhou on 8/14/22.
//

import SwiftUI
import CoreML
import Vision

struct ContentView: View
{
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var predictionText = ""
    @State private var secondaryPredictionText = ""
    
    var body: some View
    {
        NavigationView
        {
            VStack
            {
                Text(predictionText).font(.headline)
                VStack
                {
                    ZStack
                    {
                        Rectangle().fill(.secondary)
                        Text("Tap to select a photo")
                            .foregroundColor(.white)
                            .font(.headline)
                        image?
                            .resizable()
                            .scaledToFit()
                    }
                    .onTapGesture(perform: selectImage)
                    
                    VStack
                    {
                        Text(secondaryPredictionText)
                            .padding([.bottom])
                    }
                }
                .padding([.horizontal, .bottom])
                .onChange(of: inputImage){ _ in loadImage() }
                .sheet(isPresented: $showingImagePicker)
                {
                    ImagePicker(image: $inputImage)
                }
            }
        }
    }
    
    func selectImage()
    {
        showingImagePicker = true
    }
    
    func loadImage()
    {
        guard let inputImage = inputImage else {return}
        image = Image(uiImage: inputImage)
        
        classifiyImage()
    }
    
    func classifiyImage()
    {
        do
        {
            let config = MLModelConfiguration()
            let model = try FruitClassifier(configuration: config)
            let resizedImage = inputImage!.resizeImageTo(size: CGSize(width: 299, height: 299))
            let convertedImage = resizedImage?.convertToBuffer()
            let prediction = try model.prediction(image: convertedImage!)
            let predictionClass = prediction.classLabel
            var predictionProbs = prediction.classLabelProbs
            let confidence = String(format: "%.2f", predictionProbs[predictionClass]! * 100)
            predictionText = predictionClass.capitalizingFirstLetter() + ": " + confidence + "%"
            predictionProbs.removeValue(forKey: predictionClass)
            printSecondaryGuesses(predictions: predictionProbs)
        }
        catch
        {
            predictionText = "Failed to load model"
        }
    }
    
    func printSecondaryGuesses(predictions: Dictionary<String, Double>)
    {
        var predictionProbs = predictions
        let secondGuess = predictionProbs.max {$0.value < $1.value}
        predictionProbs.removeValue(forKey: secondGuess!.key)
        let secondGuessClass = secondGuess!.key
        var confidence = String(format: "%.2f", secondGuess!.value * 100)
        let secondGuessText = secondGuessClass + ": " + confidence + "%"
        
        let thirdGuess = predictionProbs.max {$0.value < $1.value}
        predictionProbs.removeValue(forKey: thirdGuess!.key)
        let thirdGuessClass = thirdGuess!.key
        confidence = String(format: "%.2f", thirdGuess!.value * 100)
        let thirdGuessText = thirdGuessClass + ": " + confidence + "%"
        
        secondaryPredictionText = secondGuessText.capitalizingFirstLetter() + "   |   " + thirdGuessText.capitalizingFirstLetter()
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
