//
//  TabsIconView.swift
//  Menual
//
//  Created by 정진균 on 2022/05/29.
//

import UIKit
import Then
import SnapKit

public enum TabsIconStatus {
    case active
    case inactive
}

public enum TabsIconStep {
    case step1
    case step2
    case step3
    case step4
}

public class TabsIconView: UIView {
    public let pathLineWidth: CGFloat = 0
    
    public var tabsIconStep: TabsIconStep = .step1 {
        didSet { setNeedsDisplay() }
    }
    
    public var tabsIconStatus: TabsIconStatus = .active {
        didSet { setNeedsDisplay() }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    public convenience init(tabsIconStatus: TabsIconStatus, tabsIconStep: TabsIconStep) {
        self.init()
        self.tabsIconStatus = tabsIconStatus
        self.tabsIconStep = tabsIconStep
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        clipsToBounds = true
        path.move(to: CGPoint(x: 0.5, y: 10.5))
        path.addLine(to: CGPoint(x: 9.5, y: 0.5))
        path.addLine(to: CGPoint(x: 14.5, y: 0.5))
        path.addLine(to: CGPoint(x: 14.5, y: 29.5))
        path.addLine(to: CGPoint(x: 4.5, y: 39.5))
        path.addLine(to: CGPoint(x: 0.5, y: 39.5))
        path.close()
        path.lineWidth = 1
        
        switch tabsIconStatus {
        case .inactive:
            switch tabsIconStep {
            case .step1:
                Colors.tint.main.v400.withAlphaComponent(0.2).setFill()
                Colors.tint.main.v400.setStroke()
            case .step2:
                Colors.tint.main.v400.withAlphaComponent(0.4).setFill()
                Colors.tint.main.v400.setStroke()
            case .step3:
                Colors.tint.main.v400.withAlphaComponent(0.6).setFill()
                Colors.tint.main.v400.setStroke()
            case .step4:
                Colors.tint.main.v400.withAlphaComponent(0.8).setFill()
                Colors.tint.main.v400.setStroke()
            }
        case .active:
            switch tabsIconStep {
            case .step1:
                Colors.grey.g800.withAlphaComponent(0.2).setFill()
                Colors.grey.g800.setStroke()
            case .step2:
                Colors.grey.g800.withAlphaComponent(0.4).setFill()
                Colors.grey.g800.setStroke()
            case .step3:
                Colors.grey.g800.withAlphaComponent(0.6).setFill()
                Colors.grey.g800.setStroke()
            case .step4:
                Colors.grey.g800.withAlphaComponent(0.7).setFill()
                Colors.grey.g800.setStroke()
            }
        }
        
        
        path.fill()
        path.stroke()
        
    }
    
    func setViews() {
        backgroundColor = .clear
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }

}
