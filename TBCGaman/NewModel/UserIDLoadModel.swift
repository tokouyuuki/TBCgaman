//
//  UserIDLoadModel.swift
//  TBCGaman
//
//  Created by 近藤大伍 on 2021/10/03.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol LoadOKDelegate_userID {
    
    func loadOK_userID(check:Int)
    
}

class UserIDLoadModel{
    
    let auth = Auth.auth()
    var userID = String()
    let db = Firestore.firestore()
    var loadOKDelegate:LoadOKDelegate_userID?
    
    func userIDLoad(date:String){
        
        if Auth.auth().currentUser != nil{

            if let userIDString = Auth.auth().currentUser?.uid{

                userID = userIDString
                UserDefaults.standard.setValue(userID, forKey: "userID")
                print("★★★★★★★★★★★★★★")
                print(userID)
                self.db.collection("TbcData").document(self.userID).setData(["tbcCount":20,"tbcPrice":500])
                loadOKDelegate?.loadOK_userID(check: 1)

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
                    
                    self.db.collection("TbcData").document(self.userID).setData(["tbcCount":20,"tbcPrice":500])
                    
                    self.loadOKDelegate?.loadOK_userID(check: 1)

                }else{
                    return
                }
            }
        }
        
        
        
    }
    
    
}

