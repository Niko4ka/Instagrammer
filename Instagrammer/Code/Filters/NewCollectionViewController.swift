import UIKit
import Foundation

class NewCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var newPostCollectionView: UICollectionView!
    
    var photos: [UIImage] = []
    var cellPhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPhotoArray()

        newPostCollectionView.register(cellType: NewCollectionViewCell.self, nib: false)
        newPostCollectionView.dataSource = self
        newPostCollectionView.delegate = self
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(of: NewCollectionViewCell.self, for: indexPath)
        cell.setPhotoToCell(photos[indexPath.item])

        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemWidth = UIScreen.main.bounds.width / 3
        let itemHeight = itemWidth

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

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = newPostCollectionView.cellForItem(at: indexPath) as? NewCollectionViewCell
        cellPhoto = cell?.photoImage
        performSegue(withIdentifier: "showFilters", sender: nil)
    }
    
    // MARK: Prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilters" {
            if let destination = segue.destination as? FiltersViewController {
                destination.cellPhoto = self.cellPhoto
            }
        }
    }
    
    private func setPhotoArray() {
        if let path = Bundle.main.resourcePath {
            let imagePath = path + "/new"
            let url = NSURL(fileURLWithPath: imagePath)
            let fileManager = FileManager.default
            
            let properties = [URLResourceKey.localizedNameKey,
                              URLResourceKey.creationDateKey,
                              URLResourceKey.localizedTypeDescriptionKey]
            
            do {
                let imageURLs = try fileManager.contentsOfDirectory(at: url as URL, includingPropertiesForKeys: properties, options:FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
                for i in 0..<imageURLs.count {
                    let imageURL = imageURLs[i]
                    let imageData = try Data(contentsOf: imageURL)
                    let image = UIImage(data: imageData)
                    if let image = image {
                        photos.append(image)
                    }
                }
            } catch let error as NSError {
                print(error.description)
            }
        }
    }

}
