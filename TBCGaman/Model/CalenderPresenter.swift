//
//  CalenderPresenter.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/29.
//

import Foundation

import Foundation

protocol ResponseForCalendar {
    func responseDateManager(response: [String])
    func responseNumberOfWeeks(response: Int)
}

class CalendarPresenter: ResponseForCalendar {

    var viewLogic: ViewLogic?
    
    func responseDateManager(response: [String]) {
        viewLogic?.daysArray = response
    }
    
    func responseNumberOfWeeks(response: Int) {
        viewLogic?.numberOfWeeks = response
    }
    
}
