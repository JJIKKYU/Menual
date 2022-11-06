//
//  PasswordIconView.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import UIKit

class PasswordIconView: UIView {
    
    enum PasswordIconViewType {
        case _default
        case typed
        case error
    }
    
    public var type: PasswordIconViewType = ._default {
        didSet { setNeedsDisplay() }
    }

    init(type: PasswordIconViewType) {
        self.type = type
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        clipsToBounds = true
        path.move(to: CGPoint(x: 0, y: 22))
        path.addLine(to: CGPoint(x: 22, y: 0))
        path.addLine(to: CGPoint(x: 33, y: 0))
        path.addLine(to: CGPoint(x: 33, y: 66))
        path.addLine(to: CGPoint(x: 11, y: 88))
        path.addLine(to: CGPoint(x: 0, y: 88))
        path.close()
        path.lineWidth = 1
        
        switch type {
        case ._default:
            Colors.grey.g800.setFill()
            break
            
        case .typed:
            Colors.tint.main.v600.setFill()
            break
            
        case .error:
            Colors.tint.system.red.r200.setFill()
            break
        }
        
        
        path.fill()
        // path.stroke()
        
    }
    
    func setViews() {
        backgroundColor = .clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        

    }

}
