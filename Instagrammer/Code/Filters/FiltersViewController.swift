import UIKit

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var filteredPhoto: UIImageView!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    
    var cellPhoto: UIImageView!
    var cellThumbnailPhoto: UIImage!
    var cachedImage: UIImage?
    
    let filterProvider = FilterProvider.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredPhoto.image = cellPhoto.image
        cellThumbnailPhoto = makeThumbnailPhoto(resizingImage: cellPhoto.image!)
        
        filtersCollectionView.register(cellType: FilterCollectionViewCell.self)
        filtersCollectionView.delegate = self
        filtersCollectionView.dataSource = self
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        filtersCollectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: - Prepare thumbnail
    
    private func makeThumbnailPhoto(resizingImage: UIImage) -> UIImage {

        let imageData = resizingImage.pngData()
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 150] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData! as CFData, nil)
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source!, 0, options)
        let thumbnail = UIImage(cgImage: imageReference!)
        return thumbnail
    }
    
    // MARK: - Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addDescriptionToPost" {
            if let destination = segue.destination as? FilterDescriptionViewController {
                destination.filteredImage = filteredPhoto.image
            }
        }
    }

}

extension FiltersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterProvider.filterArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueCell(of: FilterCollectionViewCell.self, for: indexPath)
        cell.filterImage.image = cellThumbnailPhoto
        cell.set(filter: filterProvider.filterArray[indexPath.item], toPhoto: cellThumbnailPhoto)
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        Spinner.start(from: (tabBarController?.view)!)
        
        let queue = OperationQueue()
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
        
        if cachedImage == nil {
            cachedImage = filteredPhoto.image
        }
        
        guard let chosenFilter = cell?.filterLabel.text,
            let inputImage = cachedImage else { return }
        let operation = FilterImageOperation(inputImage: inputImage, chosenFilter: chosenFilter)
        
        operation.completionBlock = {
            DispatchQueue.main.async {
                self.filteredPhoto.image = operation.outputImage
                Spinner.stop()
            }
        }
        
        queue.addOperation(operation)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth: CGFloat = 120.0
        let itemHeight = collectionView.frame.size.height
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0,
                            left: 0,
                            bottom: 0,
                            right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}
