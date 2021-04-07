
import UIKit
import SVProgressHUD

class PesquisarTC: UIViewController , UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate,
EventosView{
    func showDetalhe(evento: Evento) {
        
    }
    
    
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            self.searchBar.delegate = self
        }
        
        
    }
    var eventos:Array<Evento> = Array<Evento>()
    var mUserActionListener:EventosUserActionListener!
    var pagina:Int = 1
    var query: String = "Not"
    var pesquisado:Bool = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
       
        let backButton = UIBarButtonItem()
        backButton.tintColor = UIColor.init(hex: "F1025D")
        nav?.topItem?.backBarButtonItem = backButton
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.switchOrientation(to: .portrait)
        }
        self.mUserActionListener = EventosPresenter(mView: self)
        
        // Do any additional setup after loading the view.
        self.tableView.layoutIfNeeded()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "CelulaEventoComum", bundle: Bundle.main ), forCellReuseIdentifier: "cell1")
        
        self.tableView.register(UINib(nibName: "CelulaDestaque", bundle: Bundle.main ), forCellReuseIdentifier: "cell2")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let lastIndex:Int = self.eventos.count - 1
        if indexPath.row == lastIndex {
            if self.mUserActionListener.isNextPage()  {
                
                self.mUserActionListener.onLoadEventosPesquisa(pagina: pagina, query: query)
                self.pagina += 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
    
    // search bar
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismissKeyboard()
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == false{
            self.dismissKeyboard()
            searchBar.showsCancelButton = false
            self.query = searchBar.text!
            self.pagina = 1
            self.mUserActionListener.onLoadEventosPesquisa(pagina: pagina, query: query)
            self.pagina += 1
            self.pesquisado = true
            
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
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
