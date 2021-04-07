

import UIKit
import SVProgressHUD

class LoginVC: UIViewController, LoginView {

    var mUserActionListener:LoginUserActionListener!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var recuperarSenha: UIButton!
    @IBOutlet weak var cadastrar: UIButton!
    var isKeyboardAppear = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        nav?.backgroundColor = .clear
        nav?.isTranslucent = true
        nav?.isHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mUserActionListener = LoginPresenter(mView: self)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        self.email.shadowViewRound(corBora: "270A55", corFundo: "FFFFFF", corner: 12)
        self.email.setLeftPaddingPoints(10)
        self.email.setRightPaddingPoints(10)
        
        self.senha.shadowViewRound(corBora: "270A55", corFundo: "FFFFFF", corner: 12)
        self.senha.setLeftPaddingPoints(10)
        self.senha.setRightPaddingPoints(10)
        
        self.recuperarSenha.shadowViewRound(corBora: "270A55", corFundo: "FFFFFF", corner: 16)
        self.cadastrar.shadowViewRound(corBora: "270A55", corFundo: "FFFFFF", corner: 16)
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
    
    func showErrorDialog(titulo: String, msg: String) {
        DispatchQueue.main.async {
            self.showAlertSimple(title: titulo, message: msg)
        }    }
    
    func showProgressDialog(show: Bool) {
        DispatchQueue.main.async {
            if show {
                SVProgressHUD.show();
            }
            if !show {
                SVProgressHUD.dismiss();
            }
        }
    }
    @IBAction func entrar(_ sender: Any) {
        if self.mUserActionListener.validatorFields() {
            self.mUserActionListener.onLoadCheckLogin(email: self.email.text! , senha: self.senha.text!)
        }
    }
    
    func goHome() {
        //OperationQueue.main.addOperation {
        DispatchQueue.main.async {
            let properties:NSDictionary = [
                "USUARIO":  "logado"]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dadosLogado"), object: nil, userInfo: properties as? [AnyHashable : Any])
            self.performSegue(withIdentifier: "goHome", sender: nil)
        }
    }
    
    func validatorFields() -> Bool {
        var validacao:Bool = false
        if !self.email.text!.isEmpty {
            validacao = true
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "E-mail deve ser informado")
        }
        if !self.senha.text!.isEmpty {
            validacao = true
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Senha deve ser informada")
        }
        
        return validacao
    }

}
