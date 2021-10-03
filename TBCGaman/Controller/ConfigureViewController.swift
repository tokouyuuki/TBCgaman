//
//  ConfigureViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit

class ConfigureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var tableView: UITableView!
    let configurationNameArray = ["ご意見・ご要望・バグ報告","タバコの値段と本数"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configurationNameArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.selectionStyle = .none
        
        let configurationName = cell.contentView.viewWithTag(1) as! UILabel
        configurationName.text = configurationNameArray[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            performSegue(withIdentifier: "WebVC", sender: nil)
            
        }else if indexPath.row == 1{
            
            performSegue(withIdentifier: "TbcVC", sender: nil)
            
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "WebVC"{
            
            let WecVC = segue.destination as! WebViewController
            
        }else if segue.identifier == "TbcVC"{
            
            let TbcVC = segue.destination as! TbcViewController
            
        }
        
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
