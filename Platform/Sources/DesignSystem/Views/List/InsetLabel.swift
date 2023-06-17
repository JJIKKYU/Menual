//
//  InsetLabel.swift
//  
//
//  Created by 정진균 on 2023/05/20.
//

import UIKit

public class InsetLabel: UILabel {
    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8) // 원하는 여백을 설정합니다.
        super.drawText(in: rect.inset(by: insets))
    }
}
