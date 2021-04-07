

import UIKit
import CropViewController
import ImagePicker
import SVProgressHUD

class PerfilVC: UIViewController, PerfilView, ImagePickerDelegate,
CropViewControllerDelegate {
    
    var mUserActionListener:PerfilUserActionListener!
    @IBOutlet weak var endereco: UITextField!
    @IBOutlet weak var datanascimento: UITextField!
    @IBOutlet weak var rg: UITextField!
    @IBOutlet weak var cpf: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sobrenome: UITextField!
    @IBOutlet weak var nome: UITextField!
    @IBOutlet weak var viewFundo: UIView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var viewBody: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    var isKeyboardAppear = false
    let imagePickerController = ImagePickerController()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePickerController.delegate = self
        self.imagePickerController.imageLimit = 1
        self.mUserActionListener = PerfilPresenter(mView: self)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().rearViewRevealOverdraw = 0
        // Do any additional setup after loading the view.
        self.viewBody.shadowViewRoundUtil(8)
        self.img.viewRoundSemBg(corBora: "F1025D", corner: Int(self.img.frame.width / 2))
        self.viewFundo.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        
        self.endereco.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.endereco.setLeftPaddingPoints(10)
        self.endereco.setRightPaddingPoints(10)
        
        self.datanascimento.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.datanascimento.setLeftPaddingPoints(10)
        self.datanascimento.setRightPaddingPoints(10)
        
        self.rg.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.rg.setLeftPaddingPoints(10)
        self.rg.setRightPaddingPoints(10)
        
        self.cpf.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.cpf.setLeftPaddingPoints(10)
        self.cpf.setRightPaddingPoints(10)
        
        self.email.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.email.setLeftPaddingPoints(10)
        self.email.setRightPaddingPoints(10)
        
        self.sobrenome.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.sobrenome.setLeftPaddingPoints(10)
        self.sobrenome.setRightPaddingPoints(10)
        
        self.nome.shadowViewRound(corBora: "E9E9E9", corFundo: "FFFFFF", corner: 8)
        self.nome.setLeftPaddingPoints(10)
        self.nome.setRightPaddingPoints(10)
        
        let galeria = UITapGestureRecognizer(target: self, action: #selector(PerfilVC.printImage))
        img.addGestureRecognizer(galeria)
        img.isUserInteractionEnabled = true
        
        //present(self.imagePickerController, animated: true, completion: nil)
        mUserActionListener.onLoadPerfil()
    }
    
    @objc func printImage(){
        present(self.imagePickerController, animated: true, completion: nil)
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
    
    @IBAction func atualizar(_ sender: Any) {
        if mUserActionListener.validateField() {
            self.mountRequest()
        }
    }
    
    func showErrorDialog(titulo: String, msg: String) {
        self.showAlertSimple(title: titulo, message: msg)
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
    
    func showPerfil(cliente: Cliente) {
        DispatchQueue.main.async {
            self.nome.text = cliente.NOME_CLIENTE ?? ""
            self.sobrenome.text = cliente.SOBRE_NOME_CLIENTE ?? ""
            self.rg.text = cliente.RG_CLIENTE ?? ""
            self.cpf.text = cliente.CPF_CLIENTE ?? ""
            self.datanascimento.text = cliente.DATA_NASCIMENTO ?? ""
            self.endereco.text = cliente.ENDERECO ?? ""
            self.email.text = cliente.EMAIL_CLIENTE ?? ""
            self.img.sd_setImage(with: URL(string: cliente.FOTO_CLIENTE  ?? ""), placeholderImage: UIImage(named: "ic_placeholder.png"))
            
        }
    }
    
    
    
    func validateField() -> Bool {
        var validacao:Bool = false
        if !self.nome.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Nome deve ser informada")
        }
        
        if !self.sobrenome.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Sobrenome deve ser informada")
        }
        
        if !self.email.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Email deve ser informada")
        }
        if !self.endereco.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Endereco deve ser informada")
        }
        
        if !self.rg.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "RG deve ser informada")
        }
        
        if !self.cpf.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "CPF deve ser informada")
        }
        
        if !self.datanascimento.text!.isEmpty {
            validacao = true
            
        } else {
            validacao = false
            self.showAlertSimple(title: "Aviso", message: "Data de nascimento deve ser informada")
        }
        
        return validacao
    }
    
    private  func getCliente() -> Cliente {
        do {
            if let j = PrefUtil.getUserDefault()?.toJSON(){
                let jsonData = try JSONSerialization.data(withJSONObject: j)
                let user:LoginDecodeAPI = try JSONDecoder().decode(LoginDecodeAPI.self, from: jsonData )
                
                return user.usuario ?? Cliente()
            }
        } catch {
            
        }
        return Cliente()
    }
    
    
    func showImageUpload(img: String) {
        DispatchQueue.main.async {
            let cliente = self.getCliente()
            
            cliente.NOME_CLIENTE = self.nome.text ?? ""
            cliente.SOBRE_NOME_CLIENTE = self.sobrenome.text ?? ""
            cliente.RG_CLIENTE = self.rg.text ?? ""
            cliente.CPF_CLIENTE = self.cpf.text ?? ""
            cliente.DATA_NASCIMENTO = self.datanascimento.text ?? ""
            cliente.ENDERECO = self.endereco.text ?? ""
            cliente.EMAIL_CLIENTE = self.email.text ?? ""
            cliente.FOTO_CLIENTE = img ?? ""
            
            let json = try? JSONEncoder().encode(cliente)
            
            PrefUtil.save(value: String(data: json!, encoding: .utf8)!, forKey: "USUARIO_LOGADO")
        }
    }
    
    func mountRequest() {
        DispatchQueue.main.async {
            let boundary = "Boundary-\(NSUUID().uuidString)"
            let params = ["NOME_CLIENTE": self.nome.text! as NSObject,
                          "EMAIL_CLIENTE": self.email.text! as NSObject,
                          "SOBRE_NOME_CLIENTE": self.sobrenome.text! as NSObject,
                          "CPF_CLIENTE": self.cpf.text! as NSObject,
                          "RG_CLIENTE": self.rg.text! as NSObject,
                          "DATA_NASCIMENTO": self.email.text!,
                          "ENDERECO": self.endereco.text! as NSObject] as [String : Any]
            
            let body = self.createRequestBody(parameters: params as! [String : NSObject], boundary: boundary)
            
            self.mUserActionListener.onSendForm(withBody: body, boundary: boundary)
        }
    }
    
    func createRequestBody(parameters: [String: NSObject], boundary: String) -> Data{
        
        let body = NSMutableData()
        
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString("--\(boundary)\r\n")
        
        return body as Data
    }
    
    func createRequestBody(parameters: [String: NSObject],image: UIImage?, boundary: String) -> Data{
        
        let body = NSMutableData()
        
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        body.appendString("--\(boundary)\r\n")
        
        if image != nil {
            let mimetype = "image/jpg"
            
            let defFileName = "imagem.jpg"
            
            let imageData = image?.jpegData(compressionQuality: 1.0)
            
            body.appendString("Content-Disposition: form-data; name=\"FOTO_CLIENTE\"; filename=\"\(defFileName)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData!)
            body.appendString("\r\n")
            
            body.appendString("--\(boundary)--\r\n")
            
        }
        
        return body as Data
    }
    
    func mountRequestUpload(image:UIImage) {
        DispatchQueue.main.async {
            let boundary = "Boundary-\(NSUUID().uuidString)"
            let params = ["COD_CLIENTE": "2" as NSObject] as! [String : NSObject]
            
            let body = self.createRequestBody(parameters: params, image: self.img.image ?? nil, boundary: boundary)
            
            self.mUserActionListener.sendPhoto(withBody: body, boundary: boundary)
        }
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.imagePickerController.dismiss(animated: true) {
            if images.count > 0 {
                let cropViewController = CropViewController(image: images[0])
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
        return
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.imagePickerController.dismiss(animated: true) {
            if images.count > 0 {
                let cropViewController = CropViewController(image: images[0])
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            }
        }
        return
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.imagePickerController.dismiss(animated: true) {
            
        }
        return
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.img.image = image
        self.mountRequestUpload(image: image)
        cropViewController.dismiss(animated: true)
        return
    }
    
}
