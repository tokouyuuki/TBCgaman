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
    var numberOfWeeks: Int = 0
    var daysArray:Array<String>!
    private var requestForCalendar: RequestForCalendar?
    
    private let date = DateItems.ThisMonth.Request()
    private let daysPerWeek = 7
    private var thisYear: Int = 0
    private var thisMonth: Int = 0
    private var today: Int = 0
    private var isToday = true
    private let dayOfWeekLabel = ["日", "月", "火", "水", "木", "金", "土"]
    private var monthCounter = 0
    
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
    var gamanCount = Int()
    var priceCount = Int()
    var tbcCount = Int()
    var lifeSpanCountLabel = String()
    
    var gamanCountOfOneDay = Int()
    var kitsuenCountOfOneDay = Int()
    
    var loadDBModel = LoadDBModel()
    var tbcCalcModel = TbcCalcModel()
    var dateString = String()
    let dateFormatter = DateFormatter()
    var userID = String()
    var year = String()
    var month = String()
    var day = String()
    
    
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
        // Do any additional setup after loading the view.
        configure()
        settingLabel()
        getToday()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        
//        cellSubTitleArray = []
//        cellSubTitleArray = ["\(loadDBModel.gamanTotal)","\(priceCount)","\(loadDBModel.smokeTotal)","\(lifeSpanCountLabel)"]
        print("daigoSubTitleArray")
        print(cellSubTitleArray)
        print("daigonumberOfWeeks1")
        print(numberOfWeeks)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadDBModel.loadOKDelegate = self
        
        
        //ここは、(year)と(month)のドキュメントパスを分けています。そして余分なとこを切り落としてます。
//        let date = Date()
//        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMdd", options: 0, locale: Locale(identifier: "ja_JP"))
//        dateString = dateFormatter.string(from: date)
       
        let calendar = Calendar(identifier: .gregorian)//.gregorian→西暦、.japanese→和暦
        let date = calendar.dateComponents([.year, .month, .day], from: Date())//何年、何月、何日を取得
        year = String(date.year!)
        month = String(date.month!)
        day = String(date.day!)
        
        userID = UserDefaults.standard.object(forKey: "userID") as! String
        loadDBModel.loadDayCount(userID: userID, year: year, month: month, day: day)
        
    }
    
    //日毎の我慢、喫煙本数を取得する
    func loadDayCountOK(check: Int) {
        
        gamanCountOfOneDay = loadDBModel.countdataSets[0].gamanCount
        kitsuenCountOfOneDay = loadDBModel.countdataSets[0].smokeCount
        print("daigoloadDaygamanCountOfOneDay")
        print(gamanCountOfOneDay)
        print(kitsuenCountOfOneDay)
        
        loadDBModel.loadMonthTotal(year: year, month: month, userID: userID)
        
    }
    
    //月の合計取得完了
    func loadMonthCountOK(check: Int) {
        lifeSpanCountLabel = tbcCalcModel.lifeSpanCalc(tbcCount: loadDBModel.smokeTotal)
        loadDBModel.loadTbcData(userID: userID)
    }
    
    //値段と一箱あたりの本数取得完了
    func loadTbcOK(check: Int) {
        //月の合計を取得
        
        priceCount = (loadDBModel.tbcDataSets[0].tbcPrice) / (loadDBModel.tbcDataSets[0].tbcCount) * (loadDBModel.gamanTotal)
        cellSubTitleArray = ["\(loadDBModel.gamanTotal)","\(priceCount)","\(loadDBModel.smokeTotal)","\(lifeSpanCountLabel)"]
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

}

//MARK:- Setting Button Items
extension CalendarViewController {
    
    private func nextMonth() {
        monthCounter += 1
        commonSettingMoveMonth()
    }
    
    private func prevMonth() {
        monthCounter -= 1
        commonSettingMoveMonth()
    }
    
    private func commonSettingMoveMonth() {
        daysArray = nil
        let moveDate = DateItems.MoveMonth.Request(monthCounter)
        requestForCalendar?.requestNumberOfWeeks(request: moveDate)
        requestForCalendar?.requestDateManager(request: moveDate)
        calendarTitleLabel.text = "\(String(moveDate.year))年\(String(moveDate.month))月"
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
        let calendarCellImageView = cell.contentView.viewWithTag(2) as! UIImageView
        
        let gamanLabelOfOneDay = cell.contentView.viewWithTag(3) as! UILabel
        gamanLabelOfOneDay.text = "我慢本数:\(gamanCountOfOneDay)"
        
        let kitsuenLabelOfDay = cell.contentView.viewWithTag(4) as! UILabel
        kitsuenLabelOfDay.text = "喫煙本数:\(kitsuenCountOfOneDay)"
        
        calendarCellImageView.isHidden = true
        gamanLabelOfOneDay.isHidden = true
        kitsuenLabelOfDay.isHidden = true
        
//        print("daigogamanCountOfOneDay")
//        print(gamanCountOfOneDay)
//
//        print("daigokitsuenCountOfOneDay")
//        print(kitsuenCountOfOneDay)
        
        if indexPath.section == 1 && daysArray[indexPath.row] != "" && (gamanCountOfOneDay > 0 || kitsuenCountOfOneDay > 0){
            calendarCellImageView.isHidden = false
            gamanLabelOfOneDay.isHidden = false
            kitsuenLabelOfDay.isHidden = false
        }
        
        let calendarlabel = cell.contentView.viewWithTag(1) as! UILabel
        calendarlabel.backgroundColor = .clear
        dayOfWeekColor(calendarlabel, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, calendarlabel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(daysArray[indexPath.row])
//        print(indexPath.row)
//        print(indexPath.section)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dayVC = storyboard.instantiateViewController(withIdentifier: "DayVC") as! DayViewController
        
        let cell:UICollectionViewCell = self.collectionView(collectionView, cellForItemAt: indexPath)
        let calendarlabel = cell.contentView.viewWithTag(1) as! UILabel
        
        dayVC.day = calendarlabel.text!
        
        if indexPath.section == 1 && daysArray[indexPath.row] != ""{
            performSegue(withIdentifier: "DayVC", sender: nil)
        }else{
            return
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        let dayVC = segue.destination as! DayViewController
//        dayVC.day =
////        dayVC.countOfOneDayDlegate = self
//
//    }
    
//    func countOfOneDay(gamanCountOfOneDay:Int,kitsuenCountOfOneDay:Int) {
//
//        self.gamanCountOfOneDay = gamanCountOfOneDay
//        self.kitsuenCountOfOneDay = kitsuenCountOfOneDay
//
//    }
    
    func sendToDayVC(){
        
        
        
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
        }else{
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
                return
            }
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, String(today) == label.text {
            label.backgroundColor = .red
            label.layer.cornerRadius = 12
            label.layer.opacity = 0.8
            label.clipsToBounds = true
        }
    }
    
}

//MARK:- UICollectionViewDelegateFlowLayout
extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let weekWidth = Int(collectionView.frame.width) / daysPerWeek
        let weekHeight = weekWidth
        let dayWidth = weekWidth
        let dayHeight = (Int(collectionView.frame.height) - weekHeight) / numberOfWeeks
        return indexPath.section == 0 ? CGSize(width: weekWidth, height: weekHeight) : CGSize(width: dayWidth, height: dayHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let surplus = Int(collectionView.frame.width) % daysPerWeek
        let margin = CGFloat(surplus)/2.0
        return UIEdgeInsets(top: 0.0, left: margin, bottom: 1.5, right: margin)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
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

        Cell.layer.masksToBounds = false
        Cell.layer.shadowOffset = CGSize(width: 0, height: 1)
        Cell.layer.shadowOpacity = 1.0
        Cell.layer.shadowRadius = 1.0
        Cell.selectionStyle = .none

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


