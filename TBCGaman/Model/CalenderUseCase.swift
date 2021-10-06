//
//  CalenderUseCase.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/28.
//

import Foundation

protocol CalendarLogic: AnyObject {
    func dateManager(year: Int, month: Int)
    func numberOfWeeks(year: Int, month: Int)
}

class CalendarUseCase: CalendarLogic {

    var responseForCalendar: ResponseForCalendar?

    private let daysPerWeek = 7
    private let isLeapYear = { (year: Int) in year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) }//tureならば閏年、falseならば平年。Bool型
    private let zellerCongruence = { (year: Int, month: Int, day: Int) in (year + year/4 - year/100 + year/400 + (13 * month + 8)/5 + day) % 7 }//year(年)、month(月)、day(日)を代入すると曜日が求められる。計算結果は0〜6の整数値のいづれかで，0が日曜日を表し，6が土曜日に当たります。

    //セルに表示する日にちを取得し、Response値（daysArray）を送っている
    func dateManager(year: Int, month: Int) {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        let numberOfCells = numberOfWeeks(year, month) * daysPerWeek
        let days = numberOfDays(year, month)
        let daysArray = alignmentOfDays(firstDayOfWeek, numberOfCells, days)
        responseForCalendar?.responseDateManager(response: daysArray)
    }

    //週の数を求め、ResponceCalenderに値（weeks）を送っている。
    func numberOfWeeks(year: Int, month: Int) {
        let weeks = numberOfWeeks(year, month)//週の数を求めるメソッド
        responseForCalendar?.responseNumberOfWeeks(response: weeks)
    }

}

//MARK:- Core Logic
extension CalendarUseCase {

    //monthが1月と2月の場合のみそれぞれに12を加え，前年の年として計算し、その計算結果をツェラーの公式に入れて曜日を求めている。
    private func dayOfWeek(_ year: Int, _ month: Int, _ day: Int) -> Int {
        var year = year
        var month = month
        //monthが1月と2月の場合のみそれぞれに12を加え，前年の年として計算します。例えば，2019年1月場合は2018年13月として計算します。
        if month == 1 || month == 2 {
            year -= 1
            month += 12
        }
        return zellerCongruence(year, month, day)
    }
    
    //週の数が四つの場合
    //この条件を満たすのは一つしかありません。それは平年の2月でかつ初日が日曜日で始まる時のみです。平年の2月は28日間しかありません。従って2月1日が日曜日から始まる時のみ28/7=4で週の数は4つになります。コードは以下のようになります。
    //!isLeapYear(year)は平年の場合はtrue（!が付いているので），dayOfWeek(year, month, 1)==0で初日が日曜日を表すので，month==2と併せてそれらの条件を満たせばconditionFourWeeks(_ year: Int)はtrueを返します。
    private func conditionFourWeeks(_ year: Int, _ month: Int) -> Bool {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        return !isLeapYear(year) && month == 2 && (firstDayOfWeek == 0)
    }

    //週の数が6つの場合
    //この条件を満たすのは、月の日数が30日間でかつ初日が土曜の場合と、月の日数が31日間で初日が金曜日か土曜日の場合に限られる。
    private func conditionSixWeeks(_ year: Int, _ month: Int) -> Bool {
        let firstDayOfWeek = dayOfWeek(year, month, 1)
        let days = numberOfDays(year, month)
        return (firstDayOfWeek == 6 && days == 30) || (firstDayOfWeek >= 5 && days == 31)
    }
    
    //週の数を求めるメソッド
    //セルの数はこのメソッドで得られた整数値に7をかければ得られる。
    private func numberOfWeeks(_ year: Int, _ month: Int) -> Int {
        if conditionFourWeeks(year, month) {
            return 4
        } else if conditionSixWeeks(year, month) {
            return 6
        } else {
            return 5
        }
    }

    //日付の数を決めるメソッド
    private func numberOfDays(_ year: Int, _ month: Int) -> Int {
        var monthMaxDay = [1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31]
        if month == 2, isLeapYear(year) {
            monthMaxDay.updateValue(29, forKey: 2)
        }
        return monthMaxDay[month]!
    }

    //１日を何曜日に入れるか決めて、それ以降の日付をdaysArrayに入れている。
    private func alignmentOfDays(_ firstDayOfWeek: Int, _ numberOfCells: Int, _ days: Int) -> [String] {
        var daysArray: [String] = []
        var dayCount = 0
        for i in 0 ... numberOfCells {
            //firstDayOfWeekは１日が何曜日か（日曜なら０、土曜なら６）の情報が入っている。
            let diff = i - firstDayOfWeek
            if diff < 0 || dayCount >= days {
                daysArray.append("")
            } else {
                daysArray.append(String(diff + 1))
                dayCount += 1
            }
        }
        return daysArray
    }

}

//例： 2019年5月のカレンダー表示
//⑴　2019年5月1日の曜日を求めfirstDayOfWeekに格納する
//-> 水曜日なのでfirstDayOfWeek=3が格納される
//
//⑵　numberOfWeek()で週の数を求め曜日の数daysPerWeekを掛けcell数を求めnumberOfCellsにその値を格納する
//-> 週の数は5なのでnumberOfCells=35が格納される
//
//(3) numberOfDays()で5月の日数を取得し，それをdaysに格納する
//-> 5月は31日間なのでdays=31が格納される
//
//（4）alignmentOfDays()でどのセルにどの日にちを入れるかを決める
//5月1日は水曜日なのでindexPath.row=3の時に"1"を表示させる。つまりindexPath.rowの値とalignmentOfDaysとの差が負の時は空（""）を表示させる。日数は31日間なのでそれを越えると同様に空（""）を表示させる。
