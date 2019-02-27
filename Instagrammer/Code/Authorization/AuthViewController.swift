import UIKit

class AuthViewController: UIViewController {
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.alpha = 0.3
        loginTextField.delegate = self
        passwordTextField.delegate = self
        
        let panGesture = UITapGestureRecognizer(target: self, action: #selector(tapOutsideTextField(gesture:)))
        self.view.addGestureRecognizer(panGesture)
        
        loginTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Spinner.start(from: self.view)
        
        let token = KeychainService.shared.readToken()

        if token != nil {
            let tokenJson = ["token" : token]
            let request = RequestService.shared.createRequest(currentCase: .checkToken, caseJson: tokenJson as [String : Any])
            AuthorizationDataProvider.shared.checkToken(request: request, successCompletion: {
                print("Token exists")
                RequestService.shared.userToken = token
                Spinner.stop()
                self.showTabBarController()
                
            }) {
                print("Offline mode enabled.")
                Alert.showOfflineModeMessage(on: self, handler: {
                    Spinner.stop()
                    self.showTabBarController()
                })
            }
        } else {
            Spinner.stop()
        }
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if loginTextField.text == "" || passwordTextField.text == "" {
            showWarning()
        } else {
            signinUser()
        }
    }
    
    private func signinUser() {
        if let login = loginTextField.text, let password = passwordTextField.text {
            
            Spinner.start(from: self.view)
            
            let signinJson = ["login" : login, "password" : password]
            
            let request = RequestService.shared.createRequest(currentCase: .signin, caseJson: signinJson)
            AuthorizationDataProvider.shared.performSignin(request: request, sender: self, successCompletion: { (token) in
                RequestService.shared.userToken = token
                KeychainService.shared.saveToken(token: token)
                self.showTabBarController()
                Spinner.stop()
            })
        }
    }
    
    public func showTabBarController() {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        
        let tabBarController = TabBarController()
        
        UIApplication.shared.keyWindow?.rootViewController = tabBarController
    }
    
    private func showWarning() {
        warningLabel.alpha = 1.0
        UIView.animate(withDuration: 0.3, delay: 0.6, options: .curveLinear, animations: {
            self.warningLabel.alpha = 0
        }, completion: nil)
    }
    
}

extension AuthViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        if passwordTextField.text != "" && loginTextField.text != "" {
            signinUser()
        } else {
            showWarning()
        }
        
        return true
    }
    
    @objc func tapOutsideTextField(gesture: UITapGestureRecognizer) {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        if let placeholder = textField.placeholder {
            switch placeholder {
            case "Login":
                if passwordTextField.text != "" && loginTextField.text != "" {
                    UIView.animate(withDuration: 0.3) {
                        self.signInButton.alpha = 1.0
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.signInButton.alpha = 0.3
                    }
                }
            case "Password":
                if passwordTextField.text != "" && loginTextField.text != "" {
                    UIView.animate(withDuration: 0.3) {
                        self.signInButton.alpha = 1.0
                    }
                } else {
                    UIView.animate(withDuration: 0.3) {
                        self.signInButton.alpha = 0.3
                    }
                }
            default:
                ()
            }
        }
    }
}
