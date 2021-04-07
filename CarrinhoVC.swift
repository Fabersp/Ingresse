
import UIKit
import RealmSwift


class CarrinhoVC: UIViewController, UITableViewDelegate,
UITableViewDataSource {
    
    
    var totalV:Double = 0.0
    var subTotalV:Double = 0.0
    var taxasV:Double = 0.0
    var qtdV:Int = 0
    //var notificationToken: NotificationToken?
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var taxas: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var qtd: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            
            self.tableView.layoutIfNeeded()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(UINib(nibName: "CelulaCarrinho", bundle: Bundle.main ), forCellReuseIdentifier: "cell")
            self.tableView.rowHeight = 182
            
        }
    }
    var carrinhoList:Array<Carrinho> = Array<Carrinho>()
    @IBOutlet weak var viewBody: UIView!
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.qtd.text =  String(0)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().rearViewRevealOverdraw = 0
        // Do any additional setup after loading the view.
        self.viewBody.shadowViewRoundUtil(8)
        self.viewBody.isHidden = true
        self.stack.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(CarrinhoVC.atualizaCarrinho(notificacao:)), name: NSNotification.Name(rawValue: "carrinho"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CarrinhoVC.removido(notificacao:)), name: NSNotification.Name(rawValue: "removido"), object: nil)
        self.addListRealm()
    }
    
    private func addListRealm(){
         DispatchQueue.main.async {
       
            if self.carrinhoList.count > 0 {
                self.carrinhoList.removeAll()
            }
            
            let currencyFormatter = NumberFormatter()
            currencyFormatter.usesGroupingSeparator = true
            currencyFormatter.numberStyle = .currency
            currencyFormatter.locale = Locale.current
            
            self.totalV = 0.0
            self.subTotalV = 0.0
            self.taxasV = 0.0
            self.qtdV = 0
            
            let realm = AppDelegate.shared.realm
            let results = realm.objects(Carrinho.self)
            
            if results.count > 0 {
                self.viewBody.isHidden = false
                self.stack.isHidden = false
                self.carrinhoList.append(contentsOf: results)
                var setoresList:Array<ItensCarrinho> = Array<ItensCarrinho>()
                setoresList.removeAll()
                
                for carrinho in self.carrinhoList {
                
                    let predicate = NSPredicate(format: "COD_EVENTO = %@", carrinho.COD_EVENTO!)
                    let results = realm.objects(ItensCarrinho.self).filter(predicate)
                   // self.notificationToken = realm.observe({ (notification, r) in
                        setoresList.append(contentsOf: results)
                        for item in setoresList {
                            
                            if item.SOMAR_TAXA == "SIM" {
                                self.totalV += (Double(item.VALOR_UNITARIO ?? "0.0")! + ((
                                    Double(item.VALOR_UNITARIO ?? "0.0")! * (Double(item.TAXA_ADMINISTRATIVA ?? "0.0")!
                                        / 100.0)) * Double(item.QTD ?? "0.0")!))
                                
                                
                            } else {
                                self.totalV += (Double(item.VALOR_UNITARIO ?? "0.0")! * Double(item.QTD ?? "0.0")!)
                                
                            }
                            
                            self.qtdV += Int(item.QTD ?? "0.0")!
                            self.subTotalV =  self.totalV
                            self.taxasV += ((Double(item.TAXA_ADMINISTRATIVA ?? "0.0")! / 100.0) * self.totalV)
                        }
                        
                   
                   // })
            
             }
                
                DispatchQueue.main.async {
                    self.total.text =  currencyFormatter.string(from: NSNumber(value: Double(self.totalV)))
                    self.subTotal.text =  currencyFormatter.string(from: NSNumber(value: Double(self.subTotalV)))
                    self.taxas.text =  currencyFormatter.string(from: NSNumber(value: Double(self.taxasV)))
                    self.qtd.text =  String(self.qtdV ?? 0)
                    self.tableView?.reloadData()
                }
            } else {
                self.viewBody.isHidden = true
                self.stack.isHidden = true
            }
            
            
        }
        
        
    }
    
    @IBAction func finalizar(_ sender: Any) {
        
    }
    
    @objc func removido(notificacao : NSNotification) {
        self.showAlertSimple(title: "Aviso", message: "Foi excluido com sucesso!")
    }
    
    @objc func atualizaCarrinho(notificacao : NSNotification) {
        self.addListRealm()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.carrinhoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CelulaCarrinho
        cell.selectionStyle = .none
        do {
        
            let predicate = NSPredicate(format: "COD_EVENTO = %@", self.carrinhoList[indexPath.row].COD_EVENTO!)
            let results = AppDelegate.shared.realm.objects(ItensCarrinho.self).filter(predicate)
            var setoresList:Array<ItensCarrinho> = Array<ItensCarrinho>()
            setoresList.append(contentsOf: results)
           // self.notificationToken = AppDelegate.shared.realm.observe({ (notification, re) in
                
                cell.showSetores(setores:  setoresList)
            //})
            
           // self.realm.invalidate()
            
        } catch {
            
        }
        cell.nome.text = self.carrinhoList[indexPath.row].NOME_EVENTO!
        cell.descricao.text = self.carrinhoList[indexPath.row].DESCRICAO!
        
        
        
        
        return cell
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
