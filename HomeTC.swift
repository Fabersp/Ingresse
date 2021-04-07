
import UIKit
import SVProgressHUD
import RealmSwift

class HomeTC: UITableViewController, EventosView {
    func showDetalhe(evento: Evento) {
        
    }
    
    
    var eventos:Array<Evento> = Array<Evento>()
    var mUserActionListener:EventosUserActionListener!
    var pagina:Int = 1
    @IBOutlet weak var menu: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = .default
        nav?.backgroundColor = .white
        nav?.isTranslucent = false
        self.tabBarController?.tabBar.isHidden = false
        
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        self.mUserActionListener = EventosPresenter(mView: self)
        
        menu.target = self.revealViewController()
        menu.action = #selector(SWRevealViewController.revealToggle(_:))
        self.revealViewController().rearViewRevealOverdraw = 0
        
        self.tableView.layoutIfNeeded()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "CelulaEventoComum", bundle: Bundle.main ), forCellReuseIdentifier: "cell1")
        
        self.tableView.register(UINib(nibName: "CelulaDestaque", bundle: Bundle.main ), forCellReuseIdentifier: "cell2")
        
        
        
        self.mUserActionListener.onLoadEventos(pagina: self.pagina)
        self.pagina += 1
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goDetalhe", sender: tableView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetalhe"{
            if let dest = segue.destination as? DetalheVC {
                
                dest.COD = "\(self.eventos[(self.tableView.indexPathForSelectedRow?.row)!].COD_EVENTO!)"
                self.tableView.deselectRow(at: self.tableView.indexPathForSelectedRow!, animated: true)
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastIndex:Int = self.eventos.count - 1
        if indexPath.row == lastIndex {
            if self.mUserActionListener.isNextPage()  {
                
                self.mUserActionListener.onLoadEventos(pagina: self.pagina)
                self.pagina += 1
            }
        }
    }
    
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.eventos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.eventos[indexPath.row].EVENTO_DESTAQUE == "NAO"){
            self.tableView.rowHeight = 120
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! CelulaEventoComum
            cell.selectionStyle = .none
            
            cell.nome.text = self.eventos[indexPath.row].NOME_EVENTO!
            cell.data.text = self.eventos[indexPath.row].DATA_REALIZACAO!
            cell.idade.text = String(self.eventos[indexPath.row].IDADE_MINIMA_PERMITIDA!)
            cell.descricao.text = self.eventos[indexPath.row].LOCAL_REALIZACAO!
            cell.img.sd_setImage(with: URL(string: self.eventos[indexPath.row].FOTO_EVENTO!), placeholderImage: UIImage(named: "ic_placeholder.png"))
            
            cell.img.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
            
            
            return cell
        }
        
        self.tableView.rowHeight = 384
        let cell2 = self.tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! CelulaDestaque
        cell2.selectionStyle = .none
        
        cell2.nome.text = self.eventos[indexPath.row].NOME_EVENTO!
        cell2.data.text = self.eventos[indexPath.row].DATA_REALIZACAO!
        cell2.idade.text = String(self.eventos[indexPath.row].IDADE_MINIMA_PERMITIDA!)
        cell2.descricao.text = self.eventos[indexPath.row].LOCAL_REALIZACAO!
        cell2.img.sd_setImage(with: URL(string: self.eventos[indexPath.row].FOTO_EVENTO!), placeholderImage: UIImage(named: "ic_placeholder.png"))
        
        cell2.img.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        return cell2
        
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
    
    func showEventos(eventos: Array<Evento>) {
        if eventos.count > 0 {
            
            self.eventos.append(contentsOf: eventos)
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
            
        } else {
            self.mUserActionListener.onLoadSnackEmptyInfo(show: true)
        }
        self.mUserActionListener.onLoadProgressDialog(show: false)
    }
    
    
}
