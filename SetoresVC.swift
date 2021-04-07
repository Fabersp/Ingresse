

import UIKit
import SVProgressHUD
import RealmSwift

class SetoresVC: UIViewController, SetoresView, UITableViewDelegate,
UITableViewDataSource {
    
    @IBOutlet weak var setores: UIImageView!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            
            self.tableView.layoutIfNeeded()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(UINib(nibName: "CelulaSetor", bundle: Bundle.main ), forCellReuseIdentifier: "cell")
            self.tableView.rowHeight = 90
            
        }
    }
    var setoresListSelecionado:Array<Setores> = Array<Setores>()
    var setoresList:Array<Setores> = Array<Setores>()
    var mUserActionListener:SetoresUserActionListener!
    var COD:String = ""
    var FOTO_EVENTO:String = ""
    var NOME_EVENTO:String = ""
    var DESCRICAO:String = ""
    var qtdadd:Int = 0
    
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
        
        // Do any additional setup after loading the view.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        
        self.setores.sd_setImage(with: URL(string: self.FOTO_EVENTO), placeholderImage: UIImage(named: "ic_placeholder.png"))
        
        self.mUserActionListener = SetoresPresenter(mView: self)
        self.mUserActionListener.onLoadSetor(cod: self.COD)
        
        // let realm = try! Realm()
        
       // print(Realm.Configuration.defaultConfiguration.fileURL)
        
    }
    
    @IBAction func adicionar(_ sender: Any) {
        if qtdadd > 0 {
            
            
            let carrinho = Carrinho()
            carrinho.COD_EVENTO = "\(self.COD)"
            carrinho.NOME_EVENTO = self.NOME_EVENTO
            carrinho.DESCRICAO = self.DESCRICAO
            
            //let realm = AppDelegate.shared.createOrUpdate(<#T##object: T##T#>)
            
           // try! realm.write {
                AppDelegate.shared.createOrUpdate(carrinho)
           // }
            
            //try! realm.write {
                for setor in self.setoresList {
                    if setor.qtd ?? 0 > 0 {
                        let item = ItensCarrinho()
                        item.COD_EVENTO = "\(self.COD)"
                        item.COD_SETOR = "\(setor.COD_SETOR!)"
                        item.NOME_SETOR = setor.NOME_SETOR!
                        item.TAXA_ADMINISTRATIVA = "\(setor.TAXA_ADMINISTRATIVA!)"
                        item.DESCRICAO = setor.DESCRICAO
                        item.QTD = "\(setor.qtd!)"
                        item.SOMAR_TAXA = setor.SOMAR_TAXA
                        item.VALOR_UNITARIO = setor.VALOR_UNITARIO
                        AppDelegate.shared.createOrUpdate(item)
                        
                    }
                }
           // }
            let properties:NSDictionary = [
                "UPDATE":  true]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "carrinho"), object: nil, userInfo: properties as? [AnyHashable : Any])
            
        } else {
            self.showErrorDialog(titulo: "Aviso", msg: "Informe a quantidade no setor desejado para continuar!")
        }
        
        let alert = UIAlertController(title: "Aviso", message: "Foi adicionado em seu carrinho de compra!", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Sair", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            self.closeView()
            
        }
        
        alert.addAction(okAction)
        
        alert.addAction(UIAlertAction(title:"Continuar", style: UIAlertAction.Style.destructive, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func closeView(){
        
        self.navigationController?.popViewController(animated: true)
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
    
    func showSnackEmptyInfo(show: Bool) {
        
    }
    
    func showSetores(setores: Array<Setores>) {
        if setores.count > 0 {
            
            self.setoresList.append(contentsOf: setores)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
        } else {
            self.mUserActionListener.onLoadSnackEmptyInfo(show: true)
        }
        self.mUserActionListener.onLoadProgressDialog(show: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.setoresList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CelulaSetor
        cell.selectionStyle = .none
        cell.qtd.text = String(self.setoresList[indexPath.row].qtd ?? 0)
        cell.nome.text = self.setoresList[indexPath.row].NOME_SETOR!
        cell.descricao.text = self.setoresList[indexPath.row].DESCRICAO!
        
        let add = CutomSetoresTapGesture(target: self, action: #selector(SetoresVC.adicionar(tapGestureRecognizer:)))
        add.COD_SETOR = self.setoresList[indexPath.row].COD_SETOR!
        add.posicao = indexPath.row
        cell.img_add.isUserInteractionEnabled = true
        cell.img_add.addGestureRecognizer(add)
        
        let remover = CutomSetoresTapGesture(target: self, action: #selector(SetoresVC.remover(tapGestureRecognizer:)))
        remover.COD_SETOR = self.setoresList[indexPath.row].COD_SETOR!
        remover.posicao = indexPath.row
        cell.img_remove.isUserInteractionEnabled = true
        cell.img_remove.addGestureRecognizer(remover)
        
        return cell
    }
    
    @objc func adicionar(tapGestureRecognizer: CutomSetoresTapGesture){
        var quantidade:Int = self.setoresList[tapGestureRecognizer.posicao].qtd ?? 0
        quantidade += 1
        qtdadd += 1
        self.setoresList[tapGestureRecognizer.posicao].qtd = quantidade
        self.tableView.reloadData()
        
    }
    
    @objc func remover(tapGestureRecognizer: CutomSetoresTapGesture){
        if qtdadd > 0 {
            qtdadd -= 1
        }
        var quantidade:Int = self.setoresList[tapGestureRecognizer.posicao].qtd ?? 0
        if quantidade > 0 {
            quantidade -= 1
        }
        self.setoresList[tapGestureRecognizer.posicao].qtd = quantidade
        self.tableView.reloadData()
        
    }
    
    
}

class CutomSetoresTapGesture: UITapGestureRecognizer {
    var posicao = Int()
    var COD_SETOR = Int()
}
