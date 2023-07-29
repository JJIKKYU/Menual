//
//  MenualBottomSheetAlarmComponentView.swift
//  Menual
//
//  Created by 정진균 on 2023/07/29.
//

import SnapKit
import Then
import UIKit

public protocol AlarmComponentDelegate: AnyObject {
    func pressedConfirmBtn(date: Date, days: [String])
}

public class MenualBottomSheetAlarmComponentView: UIView {
    public weak var deleagete: AlarmComponentDelegate?
    private var selectedDays: [String] = [] {
        didSet { setNeedsLayout() }
    }
    private let days: [String] = ["월", "화", "수", "목", "금", "토", "일"]
    private let dayTitleLabel: UILabel = .init()
    private let dayCollectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: .init())
    
    private let timeTitleLabel: UILabel = .init()
    private let timePicker: UIDatePicker = .init(frame: .zero)
    
    private let confirmBtn: BoxButton = .init(frame: .zero, btnStatus: .active, btnSize: .large)
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        dayTitleLabel.do {
            $0.text = "요일 선택"
            $0.font = .AppTitle(.title_2)
            $0.textColor = .white
        }
        
        dayCollectionView.do {
            $0.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
            let flowlayout: UICollectionViewFlowLayout = .init()
            flowlayout.itemSize = .init(width: 48, height: 48)
            flowlayout.scrollDirection = .horizontal
            flowlayout.minimumLineSpacing = 0
            flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            $0.setCollectionViewLayout(flowlayout, animated: true)
            $0.backgroundColor = .clear
            $0.allowsMultipleSelection = true
            $0.delegate = self
            $0.dataSource = self
        }
        
        timeTitleLabel.do {
            $0.text = "시간 선택"
            $0.font = .AppTitle(.title_2)
            $0.textColor = .white
        }
        
        timePicker.do {
            $0.datePickerMode = .time
            $0.preferredDatePickerStyle = .wheels
            $0.minuteInterval = 5
        }
        
        confirmBtn.do {
            $0.title = "설정하기"
            $0.addTarget(self, action: #selector(pressedConfirmBtn), for: .touchUpInside)
        }
    }
    
    private func setViews() {
        addSubview(dayTitleLabel)
        addSubview(dayCollectionView)
        addSubview(timeTitleLabel)
        addSubview(timePicker)
        addSubview(confirmBtn)
        
        dayTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        dayCollectionView.snp.makeConstraints { make in
            make.top.equalTo(dayTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(48)
        }
        
        timeTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(dayCollectionView.snp.bottom).offset(22)
        }
        
        timePicker.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(timeTitleLabel.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(timePicker.snp.bottom).offset(32)
            make.height.equalTo(48)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if selectedDays.count == 0 {
            confirmBtn.btnStatus = .inactive
        } else {
            confirmBtn.btnStatus = .active
        }
    }
}

// MARK: - CollectionView

extension MenualBottomSheetAlarmComponentView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return UICollectionViewCell() }
        
        guard let day: String = days[safe: indexPath.row] else { return UICollectionViewCell() }
        cell.date = day
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let day: String = days[safe: indexPath.row] else { return }
        print("Alarm :: Selected! \(day)")
        selectedDays.append(day)
        print("Alarm :: selectedDays = \(selectedDays)")
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let day: String = days[safe: indexPath.row] else { return }
        print("Alarm :: DeSelected! \(day)")
        selectedDays = selectedDays.filter { $0 != day }
        print("Alarm :: selectedDays = \(selectedDays)")
    }
}

// MARK: - IBAction

extension MenualBottomSheetAlarmComponentView {
    @objc
    func pressedConfirmBtn() {
        let date: Date = timePicker.date
        print("Alarm :: pressedConfirmBtn! date: \(date), selectedDays = \(selectedDays)")
        deleagete?.pressedConfirmBtn(date: date, days: selectedDays)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    MenualBottomSheetAlarmComponentView()
}
