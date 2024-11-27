import Foundation
import CoreML
import Vision

struct Result:Identifiable{
    var imageLabel: String
    var confidence: Double
    var id = UUID()
}

class Photo {
    var imageData: Data?
    var results: [Result]
    
    let modelFile = try! MobileNetV2(configuration:MLModelConfiguration())
    
    init(imageData: Data? ) {
        self.imageData = imageData
        self.results = []
        
        if imageData != nil{
            self.classifyPhoto()
        }
    }
    
    func classifyPhoto(){
        let model = try! VNCoreMLModel(for: modelFile.model)
        
        let handler = VNImageRequestHandler(data: imageData!)
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            
            guard let results = request.results as? [VNClassificationObservation] else{
                print("cannot classify")
                return
            }
            for classification in results{
                var identifier = classification.identifier
                identifier = identifier.prefix(1).capitalized + identifier.dropFirst()
                self.results.append(Result(imageLabel: identifier, confidence: Double(classification.confidence)))
            }
        }
        do{
            try handler.perform([request])
        } catch{
            print("invalid image")
        }
    }
}

class PhotoModel: ObservableObject{
    
    @Published var photo = Photo(imageData: nil)
    
    func getPhoto(imageData: Data){
        self.photo = Photo(imageData: imageData)
    }
}
