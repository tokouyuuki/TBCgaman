//
//  CalenderViewController.swift
//  TBC
//
//  Created by 近藤大伍 on 2021/09/29.
//
import UIKit

//MARK:- Protocol
protocol ViewLogic {
    var numberOfWeeks: Int { get set }
    var daysArray: [String]! { get set }
}

//MARK:- UIViewController
class CalendarViewController: UIViewController, ViewLogic {
    
    //MARK: Properties
    var numberOfWeeks: Int = 0
    var daysArray: [String]!
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
    @IBAction func prevBtn(_ sender: UIButton) { prevMonth() }
    @IBAction func nextBtn(_ sender: UIButton) { nextMonth() }
    
    
    @IBOutlet weak var tableView: UITableView!
    let cellTitleArray = ["我慢した本数","節約になったお金","喫煙本数","縮んだ寿命"]
    var cellSubTitleArray:Array<String> = []
    let cellStringArray = ["","","",""]
    let imageNameArray = ["","","",""]
    var gamanCount = Int()
    var priceCount = Int()
    var tbcCount = Int()
    var lifeSpanCountLabel = String()
    
    
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
        
        cellSubTitleArray = []
        cellSubTitleArray.append("\(gamanCount)")
        cellSubTitleArray.append("\(priceCount)円")
        cellSubTitleArray.append("\(tbcCount)")
        cellSubTitleArray.append("\(lifeSpanCountLabel)")
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
        requestForCalendar?.requestNumberOfWeeks(request: date)
        requestForCalendar?.requestDateManager(request: date)
    }
    
    private func settingLabel() {
        title = "\(String(date.year))年\(String(date.month))月"
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
        title = "\(String(moveDate.year))年\(String(moveDate.month))月"
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
        return section == 0 ? 7 : (numberOfWeeks * daysPerWeek)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.backgroundColor = .clear
        dayOfWeekColor(label, indexPath.row, daysPerWeek)
        showDate(indexPath.section, indexPath.row, cell, label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "DayVC", sender: nil)
    }
    
    private func dayOfWeekColor(_ label: UILabel, _ row: Int, _ daysPerWeek: Int) {
        switch row % daysPerWeek {
        case 0: label.textColor = .red
        case 6: label.textColor = .blue
        default: label.textColor = .black
        }
    }
    
    private func showDate(_ section: Int, _ row: Int, _ cell: UICollectionViewCell, _ label: UILabel) {
        switch section {
        case 0:
            label.text = dayOfWeekLabel[row]
            cell.selectedBackgroundView = nil
        default:
            label.text = daysArray[row]
            let selectedView = UIView()
            selectedView.backgroundColor = .blue
            cell.selectedBackgroundView = selectedView
            markToday(label)
        }
    }
    
    private func markToday(_ label: UILabel) {
        if isToday, today.description == label.text {
            label.backgroundColor = .red
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
//        contentImageView.image = UIImage(named: imageNameArray[indexPath.row])
        
        let cellTitleName = Cell.contentView.viewWithTag(2) as! UILabel
        cellTitleName.text = cellTitleArray[indexPath.row]
        
//        let cellsubTitleName = Cell.contentView.viewWithTag(3) as! UILabel
//        cellsubTitleName.text = cellSubTitleArray[indexPath.row]
        
        let cellStringName = Cell.contentView.viewWithTag(4) as! UILabel
        cellStringName.text = cellStringArray[indexPath.row]
        
        return Cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    
    
    
}


