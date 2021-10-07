//
//  ConfigureViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//
import UIKit

class ConfigureViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LoadOKDelegate {
   

    @IBOutlet weak var tableView: UITableView!
    
    var configurationNameArray:Array<String> = []
    var loadDBModel = LoadDBModel()
    var userID = String()
    var dateString = String()
    let date = Date()
    let dateFormatter = DateFormatter()
    var year = String()
    var month = String()
    var day = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
        let date = calendar.dateComponents([.year, .month, .day], from: Date())//何年、何月、何日を取得
        year = String(date.year!)
        month = String(date.month!)
        day = String(date.day!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDBModel.loadOKDelegate = self
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: date)
        loadDBModel.userIDLoad(date: dateString)
        
    }
    
    //デリゲートメソッドだぜ！！！
    func loginOK_userID(check: Int) {
        if check == 1{
            userID = loadDBModel.userID
            loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
        }
    }
    
    func loadDayCountOK(check: Int) {
        if check == 1{
            loadDBModel.loadTbcData(userID: userID)
        }
    }
    
    func loadTbcOK(check: Int) {
        if check == 1{
            
            var configLabeltext = "1箱" + "\(loadDBModel.tbcDataSets[0].tbcPrice!)" + "円" + "/" + "\(loadDBModel.tbcDataSets[0].tbcCount!)" + "本に設定"
            configurationNameArray = ["ご意見・ご要望・バグ報告","\(configLabeltext)"]
            tableView.reloadData()
            
        }
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
