import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var filterImage: UIImageView!
    @IBOutlet var filterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private let filterProvider = FilterProvider.init()
    private let queue = OperationQueue()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        filterLabel.numberOfLines = 1
        filterLabel.adjustsFontSizeToFitWidth = true
        filterLabel.minimumScaleFactor = 0.5
        
        activityIndicator.isHidden = true
        activityIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
    }
    
    public func setFilterToCell(_ filter: String, _ photo: UIImage) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        filterLabel.text = filter
        
        let operation = FilterImageOperation(inputImage: photo, chosenFilter: filter)
        
        operation.completionBlock = {
            DispatchQueue.main.async {
                self.filterImage.image = operation.outputImage
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
        
        queue.addOperation(operation)
    }

}
