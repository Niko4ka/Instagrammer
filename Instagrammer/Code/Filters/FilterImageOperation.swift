import UIKit

class FilterImageOperation: Operation {
    
    private var inputImage: UIImage
    private(set) var outputImage: UIImage!
    private var chosenFilter: String
    
    init(inputImage: UIImage, chosenFilter: String) {
        self.inputImage = inputImage
        self.chosenFilter = chosenFilter
    }
    
    override func main() {
        let context = CIContext()
        guard let coreImage = CIImage(image: inputImage) else { return }
        guard let filter = CIFilter(name: chosenFilter) else { return }
        filter.setValue(coreImage, forKey: kCIInputImageKey)
        guard let filteredImage = filter.outputImage else {return}
        guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else { return }
        outputImage = UIImage(cgImage: cgImage)
    }
}
