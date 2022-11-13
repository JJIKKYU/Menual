//
//  CalendarView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit

class CalendarView: UIView {
    
    private var presentedMonth: Int = Calendar.current.component(.month, from: Date())
    private let todayDate = Calendar.current.component(.day, from: Date())

    private let numOfDaysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    
    private lazy var calendarCollectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        
        $0.delegate = self
        $0.dataSource = self
        $0.register(DateCell.self, forCellWithReuseIdentifier: "Cell")
        
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = .blue
        addSubview(calendarCollectionView)
        
        calendarCollectionView.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }


    private func getCurrentFirstWeekday() -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())

        let day = ("\(currentYear) - \(currentMonth)-01".date?.fistDayOfTheMonth.weekday)!
        return day
    }
}

// MARK: - CollectionViewDelegate
extension CalendarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 한달 수 + 앞에 이전 달 수
        let minimumCellNumber = numOfDaysInMonth[presentedMonth - 1] - getCurrentFirstWeekday()
        
        // 7의 배수여야 하므로
        let dateNumber = minimumCellNumber % 7 == 0 ? minimumCellNumber : minimumCellNumber + (7 - (minimumCellNumber % 7))
        
        print("Reminder :: collectionview return Int = \(dateNumber)")
        // return dateNumber
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Reminder :: cellForItemAt")
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? DateCell else { return UICollectionViewCell() }
        if indexPath.item <= getCurrentFirstWeekday() - 2 {
            cell.backgroundColor = .red
        } else {
            let calcDate = indexPath.row - getCurrentFirstWeekday() + 2
            cell.date = "\(calcDate)"
            // if calcDate < todayDate && currentYear == presentYear && currentMonthIndex
        }
        
        print("Reminder :: Cell = \(cell)")
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = collectionView.frame.width / 7
//        return CGSize(width: width, height: width)
//    }
}
