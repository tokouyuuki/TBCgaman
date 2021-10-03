//
//  CalenderController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/29.
//

import Foundation

protocol RequestForCalendar: class {
    func requestNumberOfWeeks(request: DateItems.ThisMonth.Request)
    func requestDateManager(request: DateItems.ThisMonth.Request)
    
    func requestNumberOfWeeks(request: DateItems.MoveMonth.Request)
    func requestDateManager(request: DateItems.MoveMonth.Request)
}

class CalendarController: RequestForCalendar {

    var calendarLogic: CalendarLogic?
    
    func requestNumberOfWeeks(request: DateItems.ThisMonth.Request) {
        calendarLogic?.numberOfWeeks(year: request.year, month: request.month)
    }
    
    func requestDateManager(request: DateItems.ThisMonth.Request) {
        calendarLogic?.dateManager(year: request.year, month: request.month)
    }
    
    func requestDateManager(request: DateItems.MoveMonth.Request) {
        calendarLogic?.dateManager(year: request.year, month: request.month)
    }
    
    func requestNumberOfWeeks(request: DateItems.MoveMonth.Request) {
        calendarLogic?.numberOfWeeks(year: request.year, month: request.month)
    }
    
}
