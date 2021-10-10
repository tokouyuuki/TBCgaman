//
//  CalenderViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/29.
//
import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }//週の数の情報が入ってくる
    var daysArray:Array<String>! { get set }//セルに表示する日にちの情報が入っってくる
}

//MARK:- UIViewController
class CalendarViewController: UIViewController, ViewLogic, LoadOKDelegate {
    
    //MARK: Properties
    var numberOfWeeks: Int = 0 //週の数
    var daysArray:Array<String>! //日にちが入ってくる
    
    private var requestForCalendar: RequestForCalendar?
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var isToday = true
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    
    let zellerCongruence = { (year: Int, month: Int, day: Int) -> Int in (year + year/4 - year/100 + year/400 + (13 * month + 8)/5 + day) % 7 } //ツェラーの公式　何年何月何日の情報を入れると何曜日かわかる。（日曜０、土曜６）
    var zellerResult = Int() //ツェラーの公式で用いた結果を入れる。
    let isLeapYear = { (year: Int) in year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) }//tureならば閏年、falseならば平年。Bool型
    
    //MARK: UI Parts
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var calendarTitleLabel: UILabel!
    @IBAction func prevBtn(_ sender: UIButton) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIButton) { nextMonth() }
    @IBOutlet weak var tableView: UITableView!
    
    let cellTitleArray = ["我慢した本数","節約になったお金","喫煙本数","縮んだ寿命"]
    var cellSubTitleArray = ["","","",""]
    var cellStringArray = ["","","",""]
    let imageNameArray = ["notsmoke","cash","smoke","skull"]
    
    var priceCount = Int() //タバコの値段
    var tbcCount = Int()//タバコの本数
    var lifeSpanCountLabel = String()
    let dayOfWeek = Int()
    
    var gamanCountDictionary = [String:Int]()
    var kitsuenCountDictionary = [String:Int]()
    var gamanCountOfOneDay = Int()
    var kitsuenCountOfOneDay = Int()
    
    var loadDBModel = LoadDBModel()
    var tbcCalcModel = TbcCalcModel()
    var dateString = String()
    let dateFormatter = DateFormatter()
    var userID = String()
    var dayToDayVC = String()//DayVCに送る値。選択したセルの日にちの情報を入れる。
    var monthToDayVC = String()//DayVCに送る値。選択したセルの月の情報を入れる。
    var yearToDayVC = String()//DayVCに送る値。選択したセルの月の情報を入れる。
    
    //MARK: Initialize
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dependencyInjection()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dependencyInjection()
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        settingLabel()
        getToday()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        print("daigoSubTitleArray")
        print(cellSubTitleArray)
        print("daigonumberOfWeeks1")
        print(numberOfWeeks)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        zellerResult = zellerCongruence(thisYear,thisMonth,1)//１日が何曜日か（日曜なら０、土曜なら６）
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
        dateString = dateFormatter.string(from: Date()) //  　2021/10/4
        if UserDefaults.standard.object(forKey: "userID") != nil{
            userID = UserDefaults.standard.object(forKey: "userID") as! String
            print(userID)
            loadDBModel.loadOKDelegate = self
            loadDBModel.loadMonth(year: String(moveDate.year), month: String(moveDate.month), userID: userID)
        }else{
            loadDBModel.userIDLoad(date: dateString)
        }
    
    }
    
    func loginOK_userID(check: Int) {
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        if check == 1{
            userID = loadDBModel.userID
            loadDBModel.loadOKDelegate = self
            loadDBModel.loadMonth(year: String(moveDate.year), month: String(moveDate.month), userID: userID)
        }
    }
    
    //月の我慢本数、喫煙本数取得完了
    func loadMonthOK(check: Int, gamanCountDictionary: [String:Int], smokeCountDictionary: [String:Int]) {
        print("loadMonthOK")
        print(gamanCountDictionary)
        print(gamanCountDictionary["7"])
        self.gamanCountDictionary = gamanCountDictionary
        self.kitsuenCountDictionary = smokeCountDictionary
        loadDBModel.loadMonthTotal(year: String(thisYear), month: String(thisMonth), userID: userID)
        collectionView.reloadData()
    }
    
    //月の合計取得完了
    func loadMonthCountOK(check: Int) {
        lifeSpanCountLabel = tbcCalcModel.lifeSpanCalc(tbcCount: loadDBModel.smokeTotal)
        loadDBModel.loadTbcData(userID: userID)
    }
    
    //値段と一箱あたりの本数取得完了
    func loadTbcOK(check: Int) {
        priceCount = (loadDBModel.tbcDataSets[0].tbcPrice) / (loadDBModel.tbcDataSets[0].tbcCount) * (loadDBModel.gamanTotal)
        cellSubTitleArray = ["\(loadDBModel.gamanTotal)","\(priceCount)円","\(loadDBModel.smokeTotal)","\(lifeSpanCountLabel)"]
        var configLabeltext = "※設定画面で1箱" + "\(loadDBModel.tbcDataSets[0].tbcPrice!)" + "円" + "/" + "\(loadDBModel.tbcDataSets[0].tbcCount!)" + "本に設定中"
        cellStringArray = ["","\(configLabeltext)","","タバコ1本で寿命が5分半縮むらしいです"]
        tableView.reloadData()
    }
    
    //MARK: Setting
    private func dependencyInjection() {
        let viewController = self
        let calendarController = CalendarController()
        let calendarPresenter = CalendarPresenter()
        let calendarUseCase = CalendarUseCase()
        viewController.requestForCalendar = calendarController
        calendarController.calendarLogic = calendarUseCase
        calendarUseCase.responseForCalendar = calendarPresenter
        calendarPresenter.viewLogic = viewController
    }
    
    private func configure() {
        collectionView.dataSource = self
        collectionView.delegate = self
        //アプリを起動すると週の数の取得とセルに表示する日付の取得がCalenderControllerに要求され、CalenderControllerはその要求事項をCalenderUseCaseに伝える。
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
    }
    
    private func settingLabel() {
        calendarTitleLabel.text = "\(String(date.year))年\(String(date.month))月"
    }
    
    private func getToday() {
        thisYear = date.year
        thisMonth = date.month
        today = date.day
    }
    
    func numberOfDays(_ year: Int, _ month: Int) -> Int {
        var monthMaxDay = [1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31]
        if month == 2, isLeapYear(year) {
            monthMaxDay.updateValue(29, forKey: 2)
        }
        return monthMaxDay[month]!
    }
    
}

//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        gamanCountDictionary = [:]
        kitsuenCountDictionary = [:]
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        gamanCountDictionary = [:]
        kitsuenCountDictionary = [:]
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        calendarTitleLabel.text = "\(String(moveDate.year))年\(String(moveDate.month))月"
        loadDBModel.loadMonth(year: String(moveDate.year), month: String(moveDate.month), userID: userID)
        //        下の書き方はこれと同じ
        //        if isToday = thisYear == moveData.year && thisMonth == moveData.month{
        //            true
        //        }else{
        //            false
        //        }
        isToday = thisYear == moveDate.year && thisMonth == moveDate.month ? true : false
        collectionView.reloadData()
    }
    
}

//MARK:- UICollectionViewDataSource
extension CalendarViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        下の書き方はこれと同じ意味
        //        if section == 0{
        //            return 7
        //        }else{
        //            return (numberOfWeeks * daysPerWeek)
        //        }
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        let calendarlabel = cell.contentView.viewWithTag(1) as! UILabel
        let calendarCellImageView = cell.contentView.viewWithTag(2) as! UIImageView
        let gamanLabelOfOneDay = cell.contentView.viewWithTag(3) as! UILabel
        let kitsuenLabelOfDay = cell.contentView.viewWithTag(4) as! UILabel
        
        calendarCellImageView.isHidden = true
        gamanLabelOfOneDay.isHidden = true
        kitsuenLabelOfDay.isHidden = true
        
        calendarlabel.backgroundColor = .clear
        dayOfWeekColor(calendarlabel, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, calendarlabel)
        
        print("cellForItemAt")
        print(calendarlabel.text!)
        print(gamanCountDictionary["\(calendarlabel.text!)!"])
        print(kitsuenCountDictionary["\(calendarlabel.text!)!"])
        if calendarlabel.text! == "" || indexPath.section == 0 || kitsuenCountDictionary["\(calendarlabel.text!)"] == nil ||  gamanCountDictionary["\(calendarlabel.text!)"] == nil{
            return cell
        }else if kitsuenCountDictionary["\(calendarlabel.text!)"]! > 0 && gamanCountDictionary["\(calendarlabel.text!)"]! > 0{
            
            calendarCellImageView.image = UIImage(named: "skull")
            calendarCellImageView.isHidden = false
            gamanLabelOfOneDay.isHidden = false
            kitsuenLabelOfDay.isHidden = false
            
            kitsuenLabelOfDay.text = "喫煙本数:\(kitsuenCountDictionary["\(calendarlabel.text!)"]!)本"
            gamanLabelOfOneDay.text = "我慢本数:\(gamanCountDictionary["\(calendarlabel.text!)"]!)本"
            
        }else if kitsuenCountDictionary["\(calendarlabel.text!)"]! > 0 {
            
            calendarCellImageView.image = UIImage(named: "skull")
            calendarCellImageView.isHidden = false
            gamanLabelOfOneDay.isHidden = false
            kitsuenLabelOfDay.isHidden = false
            
            kitsuenLabelOfDay.text = "喫煙本数:\(kitsuenCountDictionary["\(calendarlabel.text!)"]!)本"
            gamanLabelOfOneDay.text = "我慢本数:0本"
            
        }else if gamanCountDictionary["\(calendarlabel.text!)"]! > 0 {
            
            calendarCellImageView.image = UIImage(systemName: "heart.circle.fill")
            calendarCellImageView.isHidden = false
            gamanLabelOfOneDay.isHidden = false
            kitsuenLabelOfDay.isHidden = false
            
            kitsuenLabelOfDay.text = "喫煙本数:0本"
            gamanLabelOfOneDay.text = "我慢本数:\(gamanCountDictionary["\(calendarlabel.text!)"]!)本"
            
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell:UICollectionViewCell = self.collectionView(collectionView, cellForItemAt: indexPath)
        let calendarlabel = cell.contentView.viewWithTag(1) as! UILabel
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        
        print("daigocalendarlabel")
        print(calendarlabel.text!)
        dayToDayVC = calendarlabel.text!
        yearToDayVC = String(moveDate.year)
        monthToDayVC = String(moveDate.month)
        print(yearToDayVC)
        print(monthToDayVC)
        
        if indexPath.section == 1 && daysArray[indexPath.row] != ""{
            performSegue(withIdentifier: "DayVC", sender: nil)
        }else{
            cell.selectedBackgroundView = nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let DayVC = segue.destination as! DayViewController
        print(monthToDayVC)
        print(yearToDayVC)
        DayVC.day = dayToDayVC
        DayVC.month = monthToDayVC
        DayVC.year = yearToDayVC
    }
    
    
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red //日曜
        case 6: label.textColor = .blue //土曜
        default: label.textColor = .black //平日
        }
    }
    
    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        if section == 0{
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        }else {
            label.text = daysArray[row]
            if label.text != ""{
                let selectedView = UIView()
                selectedView.backgroundColor = .systemGray3
                selectedView.clipsToBounds = true
                selectedView.layer.opacity = 0.5
                selectedView.layer.cornerRadius = 7
                cell.selectedBackgroundView = selectedView
                markToday(label)
            }else{
                cell.selectedBackgroundView = nil
            }
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, String(today) == label.text {
            label.backgroundColor = .red
            label.layer.cornerRadius = 5
            label.layer.opacity = 0.8
            label.clipsToBounds = true
        }
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = 23
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight - 5) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

//MARK:- TableView

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        Cell.selectionStyle = .none
        
        let cellView = Cell.contentView.viewWithTag(5) as! UIView
        cellView.layer.masksToBounds = false
        cellView.layer.cornerRadius = 15
        cellView.layer.shadowOffset = CGSize(width: 3, height: 3)
        cellView.layer.shadowOpacity = 0.5
        cellView.layer.shadowRadius = 5
        
        let contentImageView = Cell.contentView.viewWithTag(1) as! UIImageView
        contentImageView.image = UIImage(named: imageNameArray[indexPath.row])
        
        let cellTitleName = Cell.contentView.viewWithTag(2) as! UILabel
        cellTitleName.text = cellTitleArray[indexPath.row]
        
        let cellsubTitleName = Cell.contentView.viewWithTag(3) as! UILabel
        cellsubTitleName.text = cellSubTitleArray[indexPath.row]
        
        let cellStringName = Cell.contentView.viewWithTag(4) as! UILabel
        cellStringName.text = cellStringArray[indexPath.row]
        
        return Cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}


