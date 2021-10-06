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

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, LoadOKDelegate, FirstMonthLoadOKDelegate{
    
    
    
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
    

    var year = String()//追加
    var month = String()//追加
    var day = String()
//    var firstloadArray:Array<Int> = []//追加
    var firstGamanCount = Int()//追加
    var firstSmokeCount = Int()//追加
    
    var firstMonthLoadModel = FirstMonthLoadModel()//追加
    
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var gamanButton: UIButton!
    @IBOutlet weak var kitsuenButton: UIButton!
    var buttonAnimated = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    // 211003_山口
//    let userIDLoadModel = UserIDLoadModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDBModel.loadOKDelegate = self
        
        if UserDefaults.standard.object(forKey: "gamanIncrement") != nil,UserDefaults.standard.object(forKey: "smokeIncrement") != nil{
            
            gamanIncrement = UserDefaults.standard.object(forKey: "gamanIncrement") as! Int
            smokeIncrement = UserDefaults.standard.object(forKey: "smokeIncrement") as! Int
            
        }
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: date) //  　2021/10/4  <-こんな感じで値を取ってこれる
      
        
        //追加
        let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
        let date = calendar.dateComponents([.year, .month, .day], from: Date()) //何年、何月、何日を取得
        year = String(date.year!)
        month = String(date.month!)
        day = String(date.day!)
        
        
        loadDBModel.userIDLoad(date: dateString)
        
    }
    
    //追加
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        firstMonthLoadModel.firstMonthLoadOKDelegate = self
        firstMonthLoadModel.firstMonthload(userID: userID,year: year, month: month)
        
    }
    
    //追加
    func firstMonthLoadOK(firstloadArray: Array<Int>) {
        
        print("daigofirstloadArray2")
        print(firstloadArray)
        
        if firstloadArray == []{
            
            for day in 1...31 {
                
                let calendar = Calendar(identifier: .gregorian)
                var components = DateComponents()
                components.year = Int(year)
                // 日数を求めたい次の月。13になってもOK。ドキュメントにも、月もしくは月数とある
                components.month = Int(month)
                // 日数を0にすることで、前の月の最後の日になる
                components.day = day
                // 求めたい月の最後の日のDateオブジェクトを得る
                let date = calendar.date(from: components)!
                let dayCount = calendar.component(.day, from: date)
                print("うんちっち")
                print("\(month)月 \(dayCount)日")
        
                db.collection(userID).document(year).collection(month).document("\(dayCount)").setData(["gamanCount" : firstGamanCount as Any,"smokeCount" : firstSmokeCount as Any,"postDate" : Date().timeIntervalSince1970])
                
            }
        }else{
            return
        }
        
        print("daigofirstloadArray3")
        print(firstloadArray)
        
    }
    
    
    func loginOK_userID(check: Int) {
        if check == 1{
            userID = loadDBModel.userID
            loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
        }
    }
    func loadTbcOK(check: Int) {
        
        if check == 1{
            priceOfOne = loadDBModel.tbcDataSets[0].tbcPrice / loadDBModel.tbcDataSets[0].tbcCount
            priceCount = tbcCalcModel.priceCalc(gamanCount: gamanIncrement, priceOfOne: priceOfOne)
            
            lifeSpanCount = tbcCalcModel.lifeSpanCalc(tbcCount: smokeIncrement)
            //            tableView.reloadData()
            print(String(gamanIncrement))
            print("\(smokeIncrement)")
            print("\(priceCount)円")
            print("\(lifeSpanCount)")
            
            cellSubTitleArray = []
            
            
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
            
            tableView.reloadData()
            
        }
        
    }
    
    func loadDayCountOK(check: Int) {
        if check == 1{
            
            gamanCountLabel.text = String(loadDBModel.countdataSets[0].gamanCount)
            smokeCountLabel.text = String(loadDBModel.countdataSets[0].smokeCount)
            print(gamanCountLabel.text)
            print(smokeCountLabel.text)
            gamanCount = loadDBModel.countdataSets[0].gamanCount
            smokeCount = loadDBModel.countdataSets[0].smokeCount
            ////            tableView.reloadData()
            
            loadDBModel.loadTbcData(userID: userID)
            
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
        var configLabeltext = "※1箱" + "\(loadDBModel.tbcDataSets[0].tbcPrice!)" + "/" + "\(loadDBModel.tbcDataSets[0].tbcCount!)" + "に設定中"
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
        loadDBModel.loadTbcData(userID: userID)
        
        gamanCount = gamanCount + 1
        print("daigogamanCount")
        print(gamanCount)
        
        //setDataからupdateDataに変更
        db.collection(userID).document(year).collection(month).document(day).updateData(["gamanCount" : gamanCount as Any])
        loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
        tableView.reloadData()
    }
    
    @IBAction func kitsuenButton(_ sender: UIButton) {
        buttonAnimated.endAnimation(sender: sender)
        
        smokeIncrement = smokeIncrement + 1
        UserDefaults.standard.set(smokeIncrement, forKey: "smokeIncrement")
        loadDBModel.loadTbcData(userID: userID)
        
        smokeCount = smokeCount + 1
        
        //setDataからupdateDataに変更
        db.collection(userID).document(year).collection(month).document(day).updateData(["smokeCount" : smokeCount as Any])
        loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
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
