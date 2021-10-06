//
//  Load.swift
//  Test
//
//  Created by 近藤大伍 on 2021/10/05.
//

import Foundation
import Firebase
import FirebaseFirestore

protocol FirstMonthLoadOKDelegate {
    
    func firstMonthLoadOK(firstloadArray:Array<Int>)
    
}

class FirstMonthLoadModel{
    
    let db = Firestore.firestore()
    
    var dateString = String()
    let dateFormatter = DateFormatter()
    var firstloadArray:Array<Int> = []
    var firstGamanCount = Int()
    var firstSmokeCount = Int()
    
    var firstMonthLoadOKDelegate:FirstMonthLoadOKDelegate?
    

    func firstMonthload(userID:String,year:String,month:String) {

        firstloadArray = []

        db.collection(userID).document(year).collection(month).order(by: "postDate").addSnapshotListener { snapShot, error in


            if error != nil{

                print(error.debugDescription)
                return
            }


            if let snapShotDoc = snapShot?.documents{

                self.firstloadArray = []
                for doc in snapShotDoc{

                    let data = doc.data()
                    if let gamanCount = data["gamanCount"] as? Int ,let smokeCount = data["smokeCount"] as? Int  {

                        self.firstloadArray.append(gamanCount)

                    }


                }

                print("daigofirstloadArray1")
                print(self.firstloadArray)
                self.firstMonthLoadOKDelegate?.firstMonthLoadOK(firstloadArray: self.firstloadArray)


            }
        }

        
    }
    
}
