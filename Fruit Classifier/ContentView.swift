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
            let confidence = String(format: "%.2f", prediction.classLabelProbs[predictionClass]! * 100)
            predictionText = predictionClass + ": " + confidence + "%"
        }
        catch
        {
            predictionText = "Failed to load model"
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView()
    }
}
