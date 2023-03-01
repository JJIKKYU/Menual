//
//  MenualProgressView.swift
//  
//
//  Created by 정진균 on 2023/03/01.
//

import UIKit
import SnapKit
import Then

public class MenualProgressView: UIView {
    
    public var progressValue: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setViews() {
        
    }
    
    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
