//
//  DayViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit
import Firebase
import FirebaseFirestore


class DayViewController: UIViewController,LoadOKDelegate {
    
    @IBOutlet weak var swipeCard: UIView!
    @IBOutlet weak var kinenButton: UIButton!
    @IBOutlet weak var kitsuenButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var gamanLabel: UILabel!
    @IBOutlet weak var kitsuenLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var calendarVC:CalendarViewController?
    let db = Firestore.firestore()
    var userID = String()
    var dateString = String()
    let loadDBModel = LoadDBModel()
    let dateFormatter = DateFormatter()
    let date = Date()
    var year = String()
    var month = String()
    var day = String()
    
    var gamanCountOfOneDay = Int() //1日の我慢本数(増減する)
    var kitsuenCountOfOneDay = Int() //1日の喫煙本数(増減する)
    var gamanSonomamaCount = Int() //1日の我慢本数(増減しない)
    var kitsuenSonomamaCount = Int()//1日の喫煙本数(増減しない)
    var gamantukaitaiCount = Int() //gamanCountOfOneDay - gamanSonomamaCount
    var kitsuentukaitaiCount = Int() //kitsuenCountOfOneDay - kitsuenSonomamaCount
    var gamanIncrement = Int() //今までの我慢本数の合計
    var smokeIncrement = Int() //今までの喫煙本数の合計
    
    var buttonAnimated = ButtonAnimatedModel(withDuration: 0.1, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, transform: CGAffineTransform(scaleX: 0.95, y: 0.95), alpha: 0.7)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target:self, action: #selector(leftSwipe(_:)))
        leftSwipeRecognizer.direction = .left
        kitsuenButton.addGestureRecognizer(leftSwipeRecognizer)
        
        let rightSwipeRecognizer = UISwipeGestureRecognizer(target:self, action: #selector(rightSwipe(_:)))
        rightSwipeRecognizer.direction = .right
        kinenButton.addGestureRecognizer(rightSwipeRecognizer)
        
        swipeCard.layer.cornerRadius = 10
        swipeCard.layer.shadowOffset = CGSize(width: 0, height: 1)
        swipeCard.layer.shadowOpacity = 0.5
        swipeCard.layer.shadowRadius = 1.0
        swipeView.layer.cornerRadius = 10
        
        numberView.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.object(forKey: "gamanIncrement") != nil{
            gamanIncrement = UserDefaults.standard.object(forKey: "gamanIncrement") as! Int
        }
        if UserDefaults.standard.object(forKey: "smokeIncrement") != nil{
            smokeIncrement = UserDefaults.standard.object(forKey: "smokeIncrement") as! Int
        }
        print("DaygamanIncrement")
        print(gamanIncrement)
        
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: date)
        
        let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
        let date = calendar.dateComponents([.year, .month, .day], from: Date()) //何年、何月、何日を取得
        year = String(date.year!)
        month = String(date.month!)
        
        dateLabel.text = "\(year)年\(month)月\(day)日"
        
        if UserDefaults.standard.object(forKey: "userID") != nil{
            userID = UserDefaults.standard.object(forKey: "userID") as! String
        }
        print("daigoviewdidload_loadDayCount")
        print(userID)
        print(year)
        print(month)
        print(day)
        loadDBModel.loadOKDelegate = self
        loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
        
    }
    
    func loadDayCountOK(check: Int) {
        gamanSonomamaCount = loadDBModel.countdataSets[0].gamanCount
        kitsuenSonomamaCount = loadDBModel.countdataSets[0].smokeCount
        
        gamanCountOfOneDay = loadDBModel.countdataSets[0].gamanCount
        kitsuenCountOfOneDay = loadDBModel.countdataSets[0].smokeCount
        gamanLabel.text = String(gamanCountOfOneDay)
        kitsuenLabel.text = String(kitsuenCountOfOneDay)
    }
    
    func leftAnimation(){
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.swipeCard.transform = transform
        }
    }
    
    func rightAnimation(){
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform(translationX: 174, y: 0)
            self.swipeCard.transform = transform
        }
    }
    
    @objc func leftSwipe(_ sender:UISwipeGestureRecognizer){
        switch sender.direction {
        //左スワイプ時に実行したい処理
        case .left:
            leftAnimation()
            numberView.isHidden = true
        default:
            break
        }
    }
    
    @objc func rightSwipe(_ sender:UISwipeGestureRecognizer){
        switch sender.direction {
        //右スワイプ時に実行したい処理
        case .right:
            rightAnimation()
            numberView.isHidden = false
        default:
            break
        }
    }
    
    @IBAction func kitsuenButtonSwipe(_ sender: UISwipeGestureRecognizer) {
        leftSwipe(sender)
    }
    
    @IBAction func kinenButtonSwipe(_ sender: UISwipeGestureRecognizer) {
        rightSwipe(sender)
    }
    
    @IBAction func kinenButton(_ sender: UIButton) {
        leftAnimation()
        numberView.isHidden = true
    }
    
    @IBAction func kitsuenButton(_ sender: UIButton) {
        rightAnimation()
        numberView.isHidden = false
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func gamanPlusButton(_ sender: Any) {
        gamanCountOfOneDay += 1
        gamantukaitaiCount = gamanCountOfOneDay - gamanSonomamaCount
        print("差分")
        print("\(gamantukaitaiCount)")
        gamanLabel.text = String(gamanCountOfOneDay)
    }
    
    //変更
    @IBAction func gamanMinusButton(_ sender: Any) {
        if gamanCountOfOneDay == 0{
            return
        }
        gamanCountOfOneDay -= 1
        gamantukaitaiCount = gamanCountOfOneDay - gamanSonomamaCount
        print("差分")
        print("\(gamantukaitaiCount)")
        gamanLabel.text = String(gamanCountOfOneDay)
    }
    
    //変更
    @IBAction func kitsuenPlusButton(_ sender: Any) {
        kitsuenCountOfOneDay += 1
        kitsuentukaitaiCount =  kitsuenCountOfOneDay - kitsuenSonomamaCount
        print("差分")
        print("\(kitsuentukaitaiCount)")
        kitsuenLabel.text = String(kitsuenCountOfOneDay)
    }
    
    //変更
    @IBAction func kitsuenMinusButton(_ sender: Any) {
        if kitsuenCountOfOneDay == 0{
            return
        }
        kitsuenCountOfOneDay -= 1
        kitsuentukaitaiCount =  kitsuenCountOfOneDay - kitsuenSonomamaCount
        print("差分")
        print("\(kitsuentukaitaiCount)")
        kitsuenLabel.text = String(kitsuenCountOfOneDay)
    }
    
    
    @IBAction func saveButton(_ sender: Any) {
        db.collection(userID).document(year).collection(month).document(day).updateData(["smokeCount" : kitsuenCountOfOneDay as Any,"gamanCount":gamanCountOfOneDay as Any])
        
        print(gamanIncrement)
        gamanIncrement = gamanIncrement + gamantukaitaiCount
        smokeIncrement = smokeIncrement + kitsuentukaitaiCount
        
        UserDefaults.standard.set(gamanIncrement, forKey: "gamanIncrement")
        print(gamanIncrement)
        UserDefaults.standard.set(smokeIncrement, forKey: "smokeIncrement")
        
        dismiss(animated: true, completion: nil)
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
