
import UIKit
import WebKit
import SafariServices
import SVProgressHUD

extension DetalheVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated{
            
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.show(safariVC, sender: nil)
            
            
        }
        
        decisionHandler(.allow)
    }
    
}


extension DetalheVC: SFSafariViewControllerDelegate{
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        SVProgressHUD.show()
    }
    
}
class DetalheVC: UIViewController, EventosView {
    
    
    @IBOutlet weak var stack: UIStackView!
    var mUserActionListener:EventosUserActionListener!
    @IBOutlet weak var descricao: UILabel!
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var img: UIImageView!
    var COD:String = ""
    var IMAGEM:String = ""
    var NOME_EVENTO:String = ""
     var DECRICAO:String = ""
    @IBOutlet weak var webview: WKWebView!{
        didSet{
            self.webview.navigationDelegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.setBackgroundImage(UIImage(), for: .default)
        nav?.shadowImage = UIImage()
        nav?.backgroundColor = .clear
        nav?.isTranslucent = true
        nav?.barStyle = .black
        //nav?.layer.opacity = 0.1
        let backButton = UIBarButtonItem()
        backButton.title = ""
        backButton.tintColor = UIColor.init(hex: "FFFFFF")
        nav?.topItem?.backBarButtonItem = backButton
        self.tabBarController?.tabBar.isHidden = true
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stack.isHidden = true
        self.mUserActionListener = EventosPresenter(mView: self)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        
        
        // Do any additional setup after loading the view.
        self.mUserActionListener.onLoadDetalhe(cod: self.COD)
    }
    
    
    @IBAction func comprar(_ sender: Any) {
        self.performSegue(withIdentifier: "goSetores", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goSetores"{
            if let dest = segue.destination as? SetoresVC {
                
                dest.COD = self.COD
                dest.NOME_EVENTO = self.NOME_EVENTO
                dest.FOTO_EVENTO = self.IMAGEM
                dest.DESCRICAO = self.DECRICAO
                
            }
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
    
    /* override var preferredStatusBarStyle : UIStatusBarStyle {
     return .lightContent
     }*/
    
    func showSnackEmptyInfo(show: Bool) {
        
    }
    
    func showEventos(eventos: Array<Evento>) {
        
    }
    
    func showDetalhe(evento: Evento) {
        DispatchQueue.main.async {
            self.IMAGEM = evento.FOTO_EVENTO ?? ""
            self.NOME_EVENTO = evento.NOME_EVENTO ?? ""
            self.stack.isHidden = false
            self.mUserActionListener.onLoadProgressDialog(show: false)
            self.img.sd_setImage(with: URL(string: evento.FOTO_EVENTO!), placeholderImage: UIImage(named: "ic_placeholder.png"))
            self.nome.text = evento.NOME_EVENTO!
            self.descricao.text = evento.LOCAL_REALIZACAO!
            let path = Bundle.main.path(forResource: "detalhe", ofType: "html")
            let readHandle = FileHandle(forReadingAtPath: path!)
            var htmlString:String = String(data: readHandle!.readDataToEndOfFile(), encoding: .utf8) ?? ""
            
            let dataRealizacao = evento.DATA_REALIZACAO ?? ""
            let horaInicio = evento.HORARIO_INICIO ?? ""
            let horaAbertura = evento.HORARIO_ABERTURA ?? ""
            let horaEncerramento = evento.HORARIO_ENCERRAMENTO ?? ""
            let local = evento.LOCAL_REALIZACAO ?? ""
            
            self.DECRICAO = dataRealizacao + " Abertura: "+horaAbertura+" Inicio: "+horaInicio
            
            let cep = evento.CEP ?? ""
            let logradouro = evento.LOGRADOURO ?? ""
            let numero = evento.NUMERO ?? ""
            let bairro = evento.BAIRRO ?? ""
            let cidade = evento.NOME_CIDADE ?? ""
            let estado = evento.SIGLA_ESTADO ?? ""
            
            htmlString = htmlString.replacingOccurrences(of: "%REALIZACAO%", with: dataRealizacao )
            htmlString = htmlString.replacingOccurrences(of: "%HORARIO_INICIO%", with: horaInicio )
            htmlString = htmlString.replacingOccurrences(of: "%HORARIO_ABERTURA%", with: horaAbertura )
            htmlString = htmlString.replacingOccurrences(of: "%HORARIO_ENCERRAMENTO%", with: horaEncerramento )
            htmlString = htmlString.replacingOccurrences(of: "%LOCAL%", with: local )
            
            htmlString = htmlString.replacingOccurrences(of: "%CEP%", with: cep)
            htmlString = htmlString.replacingOccurrences(of: "%LOGRADOURO%", with: logradouro)
            htmlString = htmlString.replacingOccurrences(of: "%NUMERO%", with: numero)
            htmlString = htmlString.replacingOccurrences(of: "%BAIRRO%", with: bairro)
            htmlString = htmlString.replacingOccurrences(of: "%CIDADE%", with: cidade)
            htmlString = htmlString.replacingOccurrences(of: "%SIGLA_ESTADO%", with: estado)
            
            
            DispatchQueue.main.async {
                let nav = self.navigationController?.navigationBar
                
                nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hex: "FFFFFF")]
                
                let baseURL = URL(fileURLWithPath: path!)
                
                self.webview.scrollView.showsVerticalScrollIndicator = false
                self.webview.scrollView.showsHorizontalScrollIndicator = false
                self.webview.loadHTMLString(htmlString, baseURL: baseURL)
            }
        }
    }
    
}
