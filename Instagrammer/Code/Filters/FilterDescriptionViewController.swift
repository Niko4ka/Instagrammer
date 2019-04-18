import UIKit

class FilterDescriptionViewController: UIViewController {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    public var filteredImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postImage.image = filteredImage
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        
        if AuthorizationDataProvider.shared.appIsInOfflineMode {
            Alert.showOfflineModeMessage(on: self)
        } else {
            Spinner.start(from: (tabBarController?.view)!)
            
            guard let imageString = convertImageToBase64String(image: filteredImage) else {
                Alert.show(message: "Unknown error", on: self)
                return
            }
            
            let json: [String: String] = [
                "image": imageString,
                "description": descriptionTextField.text ?? ""
            ]
            
            let createPostRequest = RequestService.shared.createRequest(currentCase: APIRequestCases.postsCreate, caseJson: json)
            PostsDataProvider.shared.getPostInfo(request: createPostRequest, sender: self) { [weak self] (post) in
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadView"), object: nil, userInfo: nil)
                
                self?.tabBarController?.selectedIndex = 0
                
                if let controllers = self?.tabBarController?.viewControllers {
                    for controller in controllers {
                        if controller.isKind(of: UINavigationController.self) {
                            let navController = controller as! UINavigationController
                            navController.popToRootViewController(animated: false)
                        }
                    }
                }
            }
        }
    }
    
    private func convertImageToBase64String(image: UIImage) -> String? {
        let imageData = image.jpegData(compressionQuality: 1.0)?.base64EncodedString()
        return imageData
    }
    
}
