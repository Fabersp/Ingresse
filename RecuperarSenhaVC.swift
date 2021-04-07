

import UIKit
import SVProgressHUD

class RecuperarSenhaVC: UIViewController {

    var basePath = "";
    @IBOutlet weak var email: UITextField!
    var isKeyboardAppear = false
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        nav?.backgroundColor = .clear
        nav?.isTranslucent = true
        nav?.isHidden = false
        let backButton = UIBarButtonItem()
        backButton.tintColor = UIColor.init(hex: "F1025D")
        nav?.topItem?.backBarButtonItem = backButton
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.email.shadowViewRound(corBora: "270A55", corFundo: "FFFFFF", corner: 12)
        self.email.setLeftPaddingPoints(10)
        self.email.setRightPaddingPoints(10)

        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -=  80
                    self.view.layoutIfNeeded()
                }
            }
            isKeyboardAppear = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isKeyboardAppear {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y != 0{
                    self.view.frame.origin.y +=  80
                    self.view.layoutIfNeeded()
                }
            }
            isKeyboardAppear = false
        }
    }
    
    @IBAction func recuperar(_ sender: Any) {
        recuperar()
    }
    
    public func validar() -> Bool {
        var validacao:Bool = true
        if !self.email.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Email deve ser informada")
        }
        
        return validacao
    }
    private func recuperar(){
        if validar() {
            onStart()
        }
    }
    
    private static let configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-type": "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 2
        return config
    }()
    
    private  let session = URLSession(configuration: configuration)
    
    func onStart() {
        SVProgressHUD.show()
        self.basePath = "https://liveingresse.com.br/api/acesso/recuperar?EMAIL=\(self.email.text!)"
        guard let url = URL(string:basePath) else {return}
        
        let dataTask = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error == nil {
                guard let response = response as? HTTPURLResponse else {return}
                
                if response.statusCode == 200 || response.statusCode == 201 {
                    
                    guard let data = data else {return}
                    DispatchQueue.main.async {
                        do {
                            let br:BaseRequest = try JSONDecoder().decode(BaseRequest.self, from: data)
                            if let retorno: BaseRequest = br {
                                if retorno.error! {
                                    SVProgressHUD.dismiss()
                                    self.showAlertSimple(title: "Aviso", message: retorno.message!)
                                    
                                } else {
                                    SVProgressHUD.dismiss()
                                    self.showAlertSimple(title: "Aviso", message: retorno.message!)
                                    
                                }
                            }
                            SVProgressHUD.dismiss()
                        } catch {
                            SVProgressHUD.dismiss()
                            
                            self.showAlertWithCompletionHandler(title: "Erro", message: "Falha ao se conectar com o servidor, revise a sua conexão e tente novamente", handler: {
                                self.onStart()
                            })
                        }
                    }
                }
            } else {
                SVProgressHUD.dismiss()
                
                self.showAlertWithCompletionHandler(title: "Erro", message: "Falha ao se conectar com o servidor, revise a sua conexão e tente novamente", handler: {
                    self.onStart()
                })
            }
            
        }
        dataTask.resume()
    }

}
