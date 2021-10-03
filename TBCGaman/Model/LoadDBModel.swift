//
//  LoadDBModel.swift
//  TBCGaman
//
//  Created by 近藤大伍 on 2021/10/02.
//

import Foundation
import Firebase
import FirebaseFirestore


protocol LoadOKDelegate {
    func loadOK(check:Int)
    
}

class LoadDBModel {
    
    var loadOKDelegate:LoadOKDelegate?
    var db = Firestore.firestore()
    var countdataSets = [CountDataSets]()
    var tbcDataSets = [TbcDataSets]()
    
//    checkModelにて使用
//    var checkTbcCount:Int!
//    var checkTbcPrice:Int!
//    sendModelにて使用
//    var labelCount = Int()
    
    func loadCountLabel(userID:String, dateString:String){
        
        db.collection(userID).document(dateString).addSnapshotListener { (snapShot, error) in
            
            self.countdataSets = []
            
            if error != nil{
                
                print(error.debugDescription)
                return
            }
            
            let data = snapShot?.data()
            print("daigodata")
            print(data as Any)
            if data == nil{
                self.db.collection(userID).document(dateString).setData(["gamanCount":0,"smokeCount":0])
                
            }
            if let gamanCount = data?["gamanCount"] as? Int,let smokeCount = data?["smokeCount"] as? Int{
                
                let newDataSet = CountDataSets(smokeCount: smokeCount, gamanCount: gamanCount)
                self.countdataSets.append(newDataSet)
                print(self.countdataSets)
                
                self.loadOKDelegate?.loadOK(check: 1)
            }
        }
    }
    
    func loadTbcData(userID:String){
        
        db.collection(userID).document("TbcData").addSnapshotListener { [self] (snapShot, error) in
            
            self.tbcDataSets = []

            if error != nil{
                return
            }
            
            if let doc = snapShot?.data(){
                if let tbcCount:Int? = doc["TbcCount"] as? Int,let tbcPrice:Int? = doc["TbcPrice"] as? Int{
                    
                    let newDatas = TbcDataSets(tbcCount: tbcCount, tbcPrice: tbcPrice)
                    
                    self.tbcDataSets.append(newDatas)
                    loadOKDelegate?.loadOK(check: 2)
                }
                
            }
            
        }
        
    }
    
    

}

    
