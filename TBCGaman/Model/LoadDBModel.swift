//
//  LoadDBModel.swift
//  TBCGaman
//
//  Created by 近藤大伍 on 2021/10/02.
//

import Foundation
import Firebase
import FirebaseFirestore


@objc protocol LoadOKDelegate {
    @objc optional func loginOK_userID(check:Int)
    @objc optional func loadDayCountOK(check:Int)
    @objc optional func loadTbcOK(check:Int)
    @objc optional func loadMonthCountOK(check:Int)
}

class LoadDBModel {
    
    var loadOKDelegate:LoadOKDelegate?
    var db = Firestore.firestore()
    var countdataSets = [CountDataSets]()
    var tbcDataSets = [TbcDataSets]()
    
    
    //追加でござる
    var gamanCountArray = [Int]()
    var smokeCountArray = [Int]()
    var gamanTotal = Int()
    var smokeTotal = Int()
    //変更点！!!!!!!!!
    //  let auth = Auth.auth()
    var userID = String()
    
    //匿名ログイン　or userIDの取得をするメソッド
    //　①！　　　ここで処理が完了したら、②に行くよ！
    func userIDLoad(date:String){
        
        if Auth.auth().currentUser?.uid != nil{
            
            if let userIDString = Auth.auth().currentUser?.uid{
                
                userID = userIDString
                UserDefaults.standard.setValue(userID, forKey: "userID")
                print("★★★★★★★★★★★★★★")
                print(userID)
                loadOKDelegate?.loginOK_userID!(check: 1)
            }
            
        }else{
            
            Auth.auth().signInAnonymously { result, error in
                
                if error != nil{
                    return
                }
                
                if let userIDString = result?.user.uid{
                    
                    self.userID = userIDString
                    print("★★★★★★★★★★★★★★")
                    print(self.userID)
                    self.db.collection(self.userID).document(date).setData(["gamanCount":0,"smokeCount":0]) { error in

                        print(error.debugDescription)

                    }
                    
                    self.db.collection("TbcData").document(self.userID).setData(["TbcCount":20,"TbcPrice":500])
                    
                    self.loadOKDelegate?.loginOK_userID!(check: 1)
                    
                }else{
                    return
                }
            }
        }
        
    }
    
    // 1日あたりの喫煙本数、我慢本数を取得するメソッド
    //　②！　　　　ここで処理が完了したら、③に行くよ！
    func loadDayCount(userID:String, year:String, month:String, day:String){
        
        print("daigodaigodaigo")
        print(userID)
        print(year)
        print(month)
        print(day)
        db.collection(userID).document(year).collection(month).document(day).addSnapshotListener { (snapShot, error) in
            
            self.countdataSets = []
            
            if error != nil{
                
                print(error.debugDescription)
                return
            }
            
            
            let data = snapShot?.data()
            print("daigodata")
            print(data as Any)
            if data == nil{
                self.db.collection(userID).document(year).collection(month).document(day).updateData(["gamanCount":0,"smokeCount":0])
            }
            if let gamanCount = data?["gamanCount"] as? Int,let smokeCount = data?["smokeCount"] as? Int{
                
                print(String(gamanCount))
                print(String(smokeCount))
                let newDataSet = CountDataSets(smokeCount: smokeCount, gamanCount: gamanCount)
                self.countdataSets.append(newDataSet)
                print(self.countdataSets)
                
                self.loadOKDelegate?.loadDayCountOK!(check: 1)
            }
            else{
                return
            }
        }
    }
    
    //tbcのデータを取得し、なかったら送信するメソッド
    //　③！　　　　　これで、処理終わったらTableViewをreloadするよ！
    func loadTbcData(userID:String){
        
        db.collection("TbcData").document(userID).addSnapshotListener { [self] (snapShot, error) in
            
            self.tbcDataSets = []
            
            if error != nil{
                return
            }
            
            let data = snapShot?.data()
            
            if data == nil{
                
                db.collection("TbcData").document(userID).setData(["TbcCount":20,"TbcPrice":500])
                let tbcCount = 20
                let tbcPrice = 500
                let newDatas = TbcDataSets(tbcCount: tbcCount, tbcPrice: tbcPrice)
                self.tbcDataSets.append(newDatas)
                loadOKDelegate?.loadTbcOK!(check: 1)
                
            }else{
                
                
                if let tbcCount = data!["TbcCount"] as? Int,let tbcPrice = data!["TbcPrice"] as? Int{
                    print(String(tbcCount))
                    print(String(tbcPrice))
                    //
                    let newDatas = TbcDataSets(tbcCount: tbcCount, tbcPrice: tbcPrice)
                    
                    self.tbcDataSets.append(newDatas)
                    loadOKDelegate?.loadTbcOK!(check: 1)
                    
                }
                
            }
            
        }
    }
    
    // 月の我慢本数と喫煙本数の合計のデータを種痘するメソッド
    //　④！　　月毎のデータを取ってくるよ。　ちなみに次は、③に行くよ！
    func loadMonthTotal(year:String,month:String,userID:String){
        
        db.collection(userID).document(year).collection(month).addSnapshotListener { (snapShot, error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            if let snapShotDoc = snapShot?.documents{
                for doc in snapShotDoc{
                    let data = doc.data()
                    if let gamanCount = data["gamanCount"] as? Int,let smokeCount = data["smokeCount"] as? Int{
                        
                        self.gamanCountArray.append(gamanCount)
                        self.smokeCountArray.append(smokeCount)
                        
                    }
                    
                }
                let array = self.gamanCountArray
                print("Tokonums")
                print(array)

                self.gamanTotal = array.reduce(0, +)
                print("Tokototal")
                print(self.gamanTotal)
                
                let array2 = self.smokeCountArray
                print("Tokonums2")
                print(array2)
                
                self.smokeTotal = array2.reduce(0, +)
                print("Tokototal2")
                print(self.smokeTotal)
                self.gamanCountArray = []
                self.smokeCountArray = []
                self.loadOKDelegate?.loadMonthCountOK!(check: 1)
               
            }
        }
    }
}

