//
//  TbcViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/26.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol CatchProtocol {
    func catchData(tbcPrice:String,tbcCount:String)
}

class TbcViewController: UIViewController, LoadOKDelegate {
   
    var catchDataDelegate:CatchProtocol?
        var userID = String()
        var date = String()
        let db = Firestore.firestore()
        
        // let tbcDBModel = TbcDBModel()
        let loadDBModel = LoadDBModel()
        var tbcCountAc = UIAlertController()
        var tbcPriceAc = UIAlertController()
        
    
    @IBOutlet weak var tbcPriceLabel: UILabel!
    @IBOutlet weak var tbcCountLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDBModel.loadOKDelegate = self
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadTbcData(userID: userID)
        //        tbcDataModel.showLabel(tbcCountLabel: tbcCountLabel, tbcPriceLabel: tbcPriceLabel)
        
    }
    
    func loadOK(check: Int) {
        if check == 2{
                
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
                    //            self.db.collection(userName).document("TbcPrice").setData(["TbcPrice" : Int((text?.text)!)])
                    //            self.db.collection(userName).document("TbcData").updateData(["TbcPrice" : Int((text?.text)!)])
                    self.db.collection(self.userID).document("TbcData").setData(["TbcPrice" : Int((text?.text)!)], merge: true)
                    
                    
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
    
    
    @IBAction func numberLabel(_ sender: Any) {
        
        tbcCountAc = UIAlertController(title: "タバコ1箱の本数を入力してください", message: "", preferredStyle: .alert)
               let okAction = UIAlertAction(title: "OK", style: .default) {(action) in
                   
                   guard let textfiels = self.tbcCountAc.textFields else{
                       return
                   }
                   
                   let text = textfiels.first
                   self.tbcCountLabel.text = "\((text?.text)!)" + "本"
                   //            self.db.collection(userName).document("TbcCount").setData(["TbcCount" : Int((text?.text)!)])
                   //            self.db.collection(userName).document("TbcData").updateData(["TbcCount" : Int((text?.text)!)])
                   self.db.collection(self.userID).document("TbcData").setData(["TbcCount" : Int((text?.text)!)], merge: true)
                   self.tbcCountAc.textFields?.first?.text = ""
                   
                   
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
        
        catchDataDelegate?.catchData(tbcPrice: tbcPriceLabel.text!, tbcCount: tbcCountLabel.text!)
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
