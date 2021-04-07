

import UIKit
import SVProgressHUD

class DadosAcessoVC: UIViewController, CadastroView {

    var mUserActionListener:CadastroActionListener!
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var viewBody: UIView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmaremail: UITextField!
    @IBOutlet weak var senha: UITextField!
    @IBOutlet weak var confirmasenha: UITextField!
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
    
    override func viewDidAppear(_ animated: Bool) {
       
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
        self.mUserActionListener = CadastroPresenter(mView: self)
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       self.viewBody.shadowViewRoundUtil(16)
        
        self.email.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 12)
        self.email.setLeftPaddingPoints(10)
        self.email.setRightPaddingPoints(10)
        
        self.confirmaremail.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 12)
        self.confirmaremail.setLeftPaddingPoints(10)
        self.confirmaremail.setRightPaddingPoints(10)
        
        self.confirmasenha.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 12)
        self.confirmasenha.setLeftPaddingPoints(10)
        self.confirmasenha.setRightPaddingPoints(10)
        
        self.senha.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 12)
        self.senha.setLeftPaddingPoints(10)
        self.senha.setRightPaddingPoints(10)

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
    
    @IBAction func proximo(_ sender: Any) {
        if self.mUserActionListener.validatorFields(){
            self.showAlertSimple(title: "Ops", message: "Existem campos obrigatórios não preenchidos.")
            return
        }
        
        if senha.text != confirmasenha.text {
            self.showAlertSimple(title: "Ops", message: "Senha confirmada difere da senha informada")
            return
        }
        self.mUserActionListener.onPostFormAPI()
       
    }
    
    func showErrorDialog(titulo: String, msg: String) {
        DispatchQueue.main.async {
            self.showAlertSimple(title: titulo, message: msg)
        }
    }
    
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
    
    func validatorFields() -> Bool {
        
        if  nome.text?.isEmpty == true {
            return true
            
        }
        if senha.text?.isEmpty == true {
            return true
            
        }
        if confirmasenha.text?.isEmpty == true {
            return true
            
        }
        if email.text?.isEmpty == true{
            return true
            
        }
        
        if senha.text?.isEmpty == true{
            return true
            
        }
        
        if confirmasenha.text?.isEmpty == true{
            return true
            
        }
        
        return false
    }
    
    func mountForm() -> Cliente {
        let cliente = Cliente()
        cliente.NOME_CLIENTE = self.nome.text ?? ""
        cliente.EMAIL_CLIENTE = self.email.text ?? ""
        cliente.SENHA = self.senha.text ?? ""
        
        return cliente
    }

}
