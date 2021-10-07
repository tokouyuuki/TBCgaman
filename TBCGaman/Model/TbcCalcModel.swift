//
//  TbcCalcModel.swift
//  TBCGaman
//
//  Created by 近藤大伍 on 2021/09/30.
//

import Foundation
import UIKit

class TbcCalcModel{
    
    func priceCalc(gamanCount:Int,priceOfOne:Int) -> Int{
        
        let price = gamanCount * priceOfOne
        return price
        
    }
    
    
    func lifeSpanCalc(tbcCount:Int) -> String{
        
        let lifeSpanString:String
        let lifeSpan = Double(tbcCount) * 5.5
        let shou = Int(lifeSpan) / 60
        let Amari = Int(lifeSpan) % 60
        let shousuuten = lifeSpan.truncatingRemainder(dividingBy: 1)
        var second = 0
        
        if shousuuten == 0.5{
            second = 30
        }else if shousuuten == 0{
            second = 0
        }
        
        lifeSpanString = "\(shou)時間\(Amari)分\(second)秒"
        return lifeSpanString
        
    }
    
    
    
    
}

