//
//  MonthView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit

class MonthView: UIView {
    
    private var presentedMonth: Int = Calendar.current.component(.month, from: Date())
    private var presentedYear: Int = Calendar.current.component(.year, from: Date())
    
    public var yearAndMonth: String = "0000.00" {
        didSet { setNeedsLayout() }
    }
    
    private let monthLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_3)
        $0.text = "20YY년 MM월"
        $0.textColor = Colors.grey.g600
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(monthLabel)
        
        monthLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let year = yearAndMonth.split(separator: ".")[0]
        var month = yearAndMonth.split(separator: ".")[1]
        if let monthInt = Int(month),
           monthInt < 10 {
            month = "0" + month
        }
        
        monthLabel.text = "\(year)년 \(month)월"
    }

}
