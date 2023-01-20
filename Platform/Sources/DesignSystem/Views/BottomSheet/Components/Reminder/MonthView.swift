//
//  MonthView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit
import MenualUtil

protocol MonthViewDelegate: AnyObject {
    func pressedLeftBtn()
    func pressedRightBtn()
}

class MonthView: UIView {
    
    private var presentedMonth: Int = Calendar.current.component(.month, from: Date())
    private var presentedYear: Int = Calendar.current.component(.year, from: Date())
    
    public var yearAndMonth: String = "0000.00" {
        didSet { setNeedsLayout() }
    }
    
    var isEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    weak var delegate: MonthViewDelegate?
    
    private let monthLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_3)
        $0.text = "20YY년 MM월"
        $0.textColor = Colors.grey.g600
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private lazy var leftBtn = UIButton().then { (btn: UIButton) in
        btn.actionName = "prev"
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(Asset._24px.Arrow.back.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = Colors.grey.g600
        btn.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.addTarget(self, action: #selector(pressedLeftBtn), for: .touchUpInside)
    }
    
    private lazy var rightBtn = UIButton().then { (btn: UIButton) in
        btn.actionName = "next"
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(Asset._24px.Arrow.front.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.tintColor = Colors.grey.g200
        btn.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        btn.addTarget(self, action: #selector(pressedRightBtn), for: .touchUpInside)
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
        addSubview(leftBtn)
        addSubview(rightBtn)
        
        monthLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        leftBtn.snp.makeConstraints { make in
            make.trailing.equalTo(monthLabel.snp.leading).offset(-16)
            make.centerY.equalTo(monthLabel)
            make.width.height.equalTo(24)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.leading.equalTo(monthLabel.snp.trailing).offset(16)
            make.centerY.equalTo(monthLabel)
            make.width.height.equalTo(24)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let year = yearAndMonth.split(separator: ".")[0]
        var month = yearAndMonth.split(separator: ".")[1]
        if month.count == 1 {
            month = "0" + month
        }
        
        monthLabel.text = "\(year)년 \(month)월"
        
        switch isEnabled {
        case true:
            monthLabel.textColor = Colors.grey.g100
            rightBtn.tintColor = Colors.grey.g100
            if Int(year) == presentedYear && Int(month) == presentedMonth {
                leftBtn.tintColor = Colors.grey.g600
            } else {
                leftBtn.tintColor = Colors.grey.g100
            }
            leftBtn.isUserInteractionEnabled = true
            rightBtn.isUserInteractionEnabled = true
            
        case false:
            monthLabel.textColor = Colors.grey.g600
            rightBtn.tintColor = Colors.grey.g600
            leftBtn.tintColor = Colors.grey.g600
            leftBtn.isUserInteractionEnabled = false
            rightBtn.isUserInteractionEnabled = false
        }
    }

}

// MARK: - IBAction
extension MonthView {
    @objc
    func pressedLeftBtn(_ button: UIButton) {
        delegate?.pressedLeftBtn()
        MenualLog.logEventAction(responder: button)
    }
    
    @objc
    func pressedRightBtn(_ button: UIButton) {
        delegate?.pressedRightBtn()
        MenualLog.logEventAction(responder: button)
    }
}
