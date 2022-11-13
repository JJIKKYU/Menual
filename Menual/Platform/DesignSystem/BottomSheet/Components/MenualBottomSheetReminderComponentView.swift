//
//  MenualBottomSheetReminderComponentView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/13.
//

import UIKit
import Then
import SnapKit

class MenualBottomSheetReminderComponentView: UIView {
    
    private let reminderTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g200
        $0.font = UIFont.AppBodyOnlyFont(.body_3)
        $0.text = "선택한 날짜에 알람 받기"
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
