//
//  CalenderController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/29.
//

import Foundation

//クラスにのみ適用できるようにする（classではなくAnyObjectが推奨されている）
protocol RequestForCalendar: class {
    func requestNumberOfWeeks(request: DateItems.ThisMonth.Request)
    func requestDateManager(request: DateItems.ThisMonth.Request)
    
    func requestNumberOfWeeks(request: DateItems.MoveMonth.Request)
    func requestDateManager(request: DateItems.MoveMonth.Request)
}

class CalendarController: RequestForCalendar {

    var calendarLogic: CalendarLogic?
    
    //週の数を求め、ResponceCalenderに値を送っている。（今月）
    func requestNumberOfWeeks(request: DateItems.ThisMonth.Request) {
        calendarLogic?.numberOfWeeks(year: request.year, month: request.month)
    }
    
    //セルに表示する日にちを取得し、ResponceCalenderに値を送っている（今月）
    func requestDateManager(request: DateItems.ThisMonth.Request) {
        calendarLogic?.dateManager(year: request.year, month: request.month)
    }
    
    //セルに表示する日にちを取得し、ResponceCalenderに値を送っている（来月or先月）
    func requestDateManager(request: DateItems.MoveMonth.Request) {
        calendarLogic?.dateManager(year: request.year, month: request.month)
    }
    
    //週の数を求め、ResponceCalenderに値を送っている。（来月or先月）
    func requestNumberOfWeeks(request: DateItems.MoveMonth.Request) {
        calendarLogic?.numberOfWeeks(year: request.year, month: request.month)
    }
    
}
