//
//  TbcViewController.swift
//  TBCGaman
//
//  Created by 都甲裕希 on 2021/10/03.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

//protocol CatchProtocol {
//    func catchData(tbcPrice:String,tbcCount:String)
//}
class TbcViewController: UIViewController, LoadOKDelegate{
   
    
    @IBOutlet weak var tbcPriceLabel: UILabel!
    @IBOutlet weak var tbcCountLabel: UILabel!
    
     let loadDBModel = LoadDBModel()
     var tbcCountAc = UIAlertController()
     var tbcPriceAc = UIAlertController()
     
     //追加したよ！！
     var dateString = String()
     let dateFormatter = DateFormatter()
     var year = String()
     var month = String()
     var day = String()
     
     var userID = String()
     let date = Date()
     let db = Firestore.firestore()
     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: date)
        
        let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
        let date = calendar.dateComponents([.year, .month, .day], from: Date()) //何年、何月、何日を取得
        year = String(date.year!)
        month = String(date.month!)
        day = String(date.day!)
        print("daigoTbcviewdidload")
        print(year)
        print(month)
        print(day)
        
        loadDBModel.loadOKDelegate = self
        loadDBModel.userIDLoad(date: dateString)
    }
    
    
    //　追加したよ！要チェック！！
    func loginOK_userID(check: Int) {
        userID = loadDBModel.userID
        print("tokosuke")
        print(userID)
        print(year)
        print(month)
        print(day)
        loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
    }
    
    func loadDayCountOK(check: Int) {
        loadDBModel.loadTbcData(userID: userID)
    }
    
    func loadTbcOK(check: Int) {
        if check == 1{
            tbcCountLabel.text = String(loadDBModel.tbcDataSets[0].tbcCount)
            tbcPriceLabel.text = String(loadDBModel.tbcDataSets[0].tbcPrice)
            showLabel(tbcCountLabel: tbcCountLabel, tbcPriceLabel: tbcPriceLabel)
        }
    }
    
    func showLabel(tbcCountLabel:UILabel,tbcPriceLabel:UILabel){
        let checkTbcCount = loadDBModel.tbcDataSets[0].tbcCount
        let checkTbcPrice = loadDBModel.tbcDataSets[0].tbcPrice
        
        if checkTbcCount == nil{
            tbcCountLabel.text = "未入力です"
            tbcCountLabel.textColor = .red
        }else{
            tbcCountLabel.text = "\(checkTbcCount!)" + "本"
            tbcCountLabel.textColor = .black
        }
        
        if checkTbcPrice == nil{
            tbcPriceLabel.text = "未入力です"
            tbcPriceLabel.textColor = .red
            
        }else{
            tbcPriceLabel.text = "\(checkTbcPrice!)" + "円"
            tbcPriceLabel.textColor = .black
        }
    }
    
    @IBAction func priceLabel(_ sender: UITapGestureRecognizer) {
        tbcPriceAc = UIAlertController(title: "タバコ1箱の値段を入力してください", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            guard let textfiels = self.tbcPriceAc.textFields else{
                return
            }
            
            let text = textfiels.first
            self.tbcPriceLabel.text = "\((text?.text)!)" + "円"
            print(self.tbcPriceLabel.text)
            print(self.userID)
           
            self.db.collection("TbcData").document(self.userID).setData(["TbcPrice" : Int((text?.text)!)], merge: true)
            self.tbcPriceAc.textFields?.first?.text = ""
        }
        
        tbcPriceAc.addTextField { (textField:UITextField) in
            textField.placeholder = "タバコの値段"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        tbcPriceAc.addAction(okAction)
        tbcPriceAc.addAction(cancelAction)
        present(tbcPriceAc, animated: true, completion: nil)
    }
    
    @IBAction func numberLabel(_ sender: UITapGestureRecognizer) {
        tbcCountAc = UIAlertController(title: "タバコ1箱の本数を入力してください", message: "", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
            guard let textfiels = self.tbcCountAc.textFields else{
                return
            }
            
            let text = textfiels.first
            self.tbcCountLabel.text = "\((text?.text)!)" + "本"
            print(self.userID)
            self.db.collection(self.userID).document("TbcData").setData(["TbcCount" : Int((text?.text)!)], merge: true)
            self.tbcCountAc.textFields?.first?.text = ""
            self.loadDBModel.loadTbcData(userID: self.userID)
            
        }
        
        tbcCountAc.addTextField { (textField:UITextField) in
            textField.placeholder = "タバコの本数"
            textField.keyboardType = UIKeyboardType.numberPad
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        tbcCountAc.addAction(okAction)
        tbcCountAc.addAction(cancelAction)
        present(tbcCountAc, animated: true, completion: nil)
    }
    
    @IBAction func dismissButton(_ sender: Any) {
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
