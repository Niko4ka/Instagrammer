import Foundation
import UIKit

final class Alert {
    
    public static func show(message: String, on controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    
    public static func show401ErrorMessage(on controller: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Unauthorized", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            AuthorizationDataProvider.showAuthScreen()
            Spinner.stop()
        }
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    public static func showOfflineModeMessage(on controller: UIViewController, handler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: nil, message: "Offline mode", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let handler = handler else {
                return
            }
            handler()
        }
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
    
}
