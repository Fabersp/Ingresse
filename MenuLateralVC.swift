

import UIKit

class MenuLateralVC: UIViewController, UITableViewDelegate,
UITableViewDataSource {
    
    var menuList:Array<Menu> = Array<Menu>()
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            
            self.tableView.layoutIfNeeded()
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.register(UINib(nibName: "CelulaMenu", bundle: Bundle.main ), forCellReuseIdentifier: "cell")
            self.tableView.rowHeight = 40
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.isHidden = true
        nav?.barStyle = .black
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       self.menuList.append(Menu(Descricao: "Início", img: "ic_home.png", tipo: 0))
       self.menuList.append(Menu(Descricao: "Minha conta", img: "ic_perfil.png", tipo: 1))
       self.menuList.append(Menu(Descricao: "Meus ingresso", img: "ic_ingresso.png", tipo: 2))
       self.menuList.append(Menu(Descricao: "Sobre nós", img: "ic_sobre.png", tipo: 3))
       self.menuList.append(Menu(Descricao: "Política de privacidade", img: "ic_politica.png", tipo: 4))
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CelulaMenu
        cell.selectionStyle = .none
      
        cell.nome.text = self.menuList[indexPath.row].Descricao
        let image = UIImage(named: self.menuList[indexPath.row].img)
        cell.img.image =  image?.maskWithColor(color: UIColor.init(hex: "FFFFFF"))
        
        return cell
    }

}
