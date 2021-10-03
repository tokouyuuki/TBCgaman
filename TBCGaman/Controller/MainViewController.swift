//
//  MainViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, LoadOKDelegate ,LoadOKDelegate_userID{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var gamanCountLabel: UILabel!
    @IBOutlet weak var smokeCountLabel: UILabel!
    
    let cellTitleArray = ["我慢した本数","節約になったお金","喫煙本数","縮んだ寿命"]
    var cellSubTitleArray:Array<String> = []
    var cellStringArray:Array<String> = []
    let imageNameArray = ["notsmoke","cash","smoke","skull"]
    var tbcCalcModel = TbcCalcModel()
    var priceOfOne = Int()
    
    var loadDBModel = LoadDBModel()
    
    let date = Date()
    let db = Firestore.firestore()
    let dateFormatter = DateFormatter()
    var userID = String()
    
    var smokeCount = Int()
    var gamanCount = Int()
    
    var gamanIncrement = Int()
    var smokeIncrement = Int()
    var priceCount = Int()
    var lifeSpanCount = String()
    
    var dateString = String()
    var countArray = ["gamanCount":Int(),"kituenCount":Int()]
    
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var gamanButton: UIButton!
    @IBOutlet weak var kitsuenButton: UIButton!
    var buttonAnimated = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    // 211003_山口
    let userIDLoadModel = UserIDLoadModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDBModel.loadOKDelegate = self
        userIDLoadModel.loadOKDelegate = self
        
        if UserDefaults.standard.object(forKey: "gamanIncrement") != nil,UserDefaults.standard.object(forKey: "smokeIncrement") != nil{
            
            gamanIncrement = UserDefaults.standard.object(forKey: "gamanIncrement") as! Int
//            gamanTotalCount.text = String(gamanIncrement)
            smokeIncrement = UserDefaults.standard.object(forKey: "smokeIncrement") as! Int
            
        }
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: date)
        userIDLoadModel.userIDLoad(date: dateString)
        
        if userIDLoadModel.userID == ""{
            
            return
            
        }
        
        cellSubTitleArray = []
        print(String(gamanIncrement))
        print("\(smokeIncrement)")
        print("\(priceCount)円")
        print("\(lifeSpanCount)")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        shareButton.layer.cornerRadius = 10
        shareButton.layer.shadowOpacity = 0.5
        shareButton.layer.shadowRadius = 5
        shareButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        shareButton.addTarget(self,action: #selector(tapButton(_ :)),for: .touchDown)
        
        gamanButton.layer.cornerRadius = 10
        gamanButton.layer.shadowOpacity = 0.5
        gamanButton.layer.shadowRadius = 5
        gamanButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        gamanButton.addTarget(self,action: #selector(tapButton(_ :)),for: .touchDown)
        
        kitsuenButton.layer.cornerRadius = 10
        kitsuenButton.layer.shadowOpacity = 0.5
        kitsuenButton.layer.shadowRadius = 5
        kitsuenButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        kitsuenButton.addTarget(self,action: #selector(tapButton(_ :)),for: .touchDown)
        
    }
    
    func loadOK_userID(check: Int) {
        if check == 1{
            loadDBModel.loadCountLabel(userID: userIDLoadModel.userID, dateString: dateString)
            loadDBModel.loadTbcData(userID: userIDLoadModel.userID)
            userID = userIDLoadModel.userID
        }
    }
    
    func loadOK(check: Int) {
        if check == 1{
            
            gamanCountLabel.text = String(loadDBModel.countdataSets[0].gamanCount)
            smokeCountLabel.text = String(loadDBModel.countdataSets[0].smokeCount)
            print(gamanCountLabel.text)
            print(smokeCountLabel.text)
            gamanCount = loadDBModel.countdataSets[0].gamanCount
            smokeCount = loadDBModel.countdataSets[0].smokeCount
//            tableView.reloadData()
        }else if check == 2{
            print(loadDBModel.tbcDataSets)
            
            priceOfOne = loadDBModel.tbcDataSets[0].tbcPrice / loadDBModel.tbcDataSets[0].tbcCount
            priceCount = tbcCalcModel.priceCalc(gamanCount: gamanIncrement, priceOfOne: priceOfOne)
            
            lifeSpanCount = tbcCalcModel.lifeSpanCalc(tbcCount: smokeIncrement)
//            tableView.reloadData()
            
        }
    }
    
    @objc func tapButton(_ sender:UIButton){
        buttonAnimated.startAnimation(sender: sender)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let Cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        print("\(gamanIncrement)")
        
        priceCount = tbcCalcModel.priceCalc(gamanCount: gamanIncrement, priceOfOne: priceOfOne)
        lifeSpanCount = tbcCalcModel.lifeSpanCalc(tbcCount: smokeIncrement)
        cellSubTitleArray = ["\(gamanIncrement)","\(priceCount)円","\(smokeIncrement)","\(lifeSpanCount)"]
        
        print("daigoprice")
        print("\(loadDBModel.tbcDataSets[0].tbcPrice)")
        var configLabeltext = "※1箱" + "\(loadDBModel.tbcDataSets[0].tbcPrice)" + "/" + "\(loadDBModel.tbcDataSets[0].tbcCount)" + "に設定中"
        cellStringArray = ["","\(configLabeltext)","","※タバコ1本で寿命が5分半縮むらしいです"]

        Cell.layer.masksToBounds = false
        Cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        Cell.layer.shadowOpacity = 1.0
        Cell.layer.shadowRadius = 1.0
        Cell.selectionStyle = .none
        
        let contentImageView = Cell.contentView.viewWithTag(1) as! UIImageView
        contentImageView.image = UIImage(named: imageNameArray[indexPath.row])
        
        let cellTitleName = Cell.contentView.viewWithTag(2) as! UILabel
        cellTitleName.text = cellTitleArray[indexPath.row]
        
        let cellsubTitleName = Cell.contentView.viewWithTag(3) as! UILabel
        cellsubTitleName.text = cellSubTitleArray[indexPath.row]
        
        let cellStringName = Cell.contentView.viewWithTag(4) as! UILabel
        cellStringName.text = cellStringArray[indexPath.row]
        
        return Cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    @IBAction func shareButton(_ sender: UIButton) {
        buttonAnimated.endAnimation(sender: sender)
        performSegue(withIdentifier: "ShareVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShareVC"{
            
            let ShareVC = segue.destination as! ShareViewController
            
        }
    }
    
    
    @IBAction func gamanButton(_ sender: UIButton) {
        buttonAnimated.endAnimation(sender: sender)
        
        gamanIncrement = gamanIncrement + 1
        UserDefaults.standard.set(gamanIncrement, forKey: "gamanIncrement")
//        gamanTotalCount.text = String(gamanIncrement)
        loadDBModel.loadTbcData(userID: userID)
        
        gamanCount = gamanCount + 1
        print(gamanCount)
        db.collection(userID).document(dateString).setData(["gamanCount" : gamanCount as Any,"smokeCount" : smokeCount as Any])
        loadDBModel.loadCountLabel(userID: userID, dateString: dateString)
        tableView.reloadData()
    }
    
    @IBAction func kitsuenButton(_ sender: UIButton) {
        buttonAnimated.endAnimation(sender: sender)
        
        smokeIncrement = smokeIncrement + 1
        UserDefaults.standard.set(smokeIncrement, forKey: "smokeIncrement")
//        smokeTotalCount.text = String(smokeIncrement)
        loadDBModel.loadTbcData(userID: userID)
        
        smokeCount = smokeCount + 1
        db.collection(userID).document(dateString).setData(["gamanCount" : gamanCount as Any,"smokeCount" : smokeCount as Any])
        loadDBModel.loadCountLabel(userID: userID, dateString: dateString)
        tableView.reloadData()
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
