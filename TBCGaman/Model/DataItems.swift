
import Foundation
import UIKit

enum DateItems {
    
    //日にち（何年何月何日）の取得
    
    
    enum ThisMonth {
        struct Request {

            var year: Int
            var month: Int
            var day: Int

            init() {
                let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
                let date = calendar.dateComponents([.year, .month, .day], from: Date())//何年、何月、何日を取得
                year = date.year!
                month = date.month!
                day = date.day!
            }
        }
    }

    enum MoveMonth {
        struct Request {

            var year: Int
            var month: Int

            init(_ monthCounter: Int) {
                let calendar = Calendar(identifier: .gregorian)
                //月の加算、減算をしている
                let date = calendar.date(byAdding: .month, value: monthCounter, to: Date())
                let newDate = calendar.dateComponents([.year, .month], from: date!)
                year = newDate.year!
                month = newDate.month!
            }
        }
    }

}
