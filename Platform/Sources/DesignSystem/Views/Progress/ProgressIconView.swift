//
//  ProgressIconView.swift
//  
//
//  Created by 정진균 on 2023/03/01.
//

import UIKit
import Then
import SnapKit

class ProgressIconView: UIView {

    public var progressValue: CGFloat = 0 {
        didSet { setNeedsLayout() }
    }
    
    let gradientLayer = CAGradientLayer().then {
        $0.frame = CGRect(x: 0, y: 0, width: 71, height: 67)
        $0.colors = [Colors.tint.main.v800.cgColor, Colors.tint.main.v400.cgColor]
        $0.locations = [0.0, 0.0]
        $0.startPoint = CGPoint(x: 0.0, y: 0.5)
        $0.endPoint = CGPoint(x: 1.0, y: 0.5)
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
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.5, y: 17))
        path.addLine(to: CGPoint(x: 0.5, y: 66.5))
        path.addLine(to: CGPoint(x: 10.5, y: 66.5))
        path.addLine(to: CGPoint(x: 20.5, y: 58))
        path.addLine(to: CGPoint(x: 20.5, y: 66.5))
        path.addLine(to: CGPoint(x: 30.5, y: 66.5))
        path.addLine(to: CGPoint(x: 40.5, y: 58))
        path.addLine(to: CGPoint(x: 40.5, y: 66.5))
        path.addLine(to: CGPoint(x: 50.5, y: 66.5))
        path.addLine(to: CGPoint(x: 70.5, y: 50))
        path.addLine(to: CGPoint(x: 70.5, y: 0.5))
        path.addLine(to: CGPoint(x: 60.5, y: 0.5))
        path.addLine(to: CGPoint(x: 50.5, y: 8.5))
        path.addLine(to: CGPoint(x: 50.5, y: 0.5))
        path.addLine(to: CGPoint(x: 40.5, y: 0.5))
        path.addLine(to: CGPoint(x: 30.5, y: 8.5))
        path.addLine(to: CGPoint(x: 30.5, y: 0.5))
        path.addLine(to: CGPoint(x: 20.5, y: 0.5))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.black.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1

        gradientLayer.mask = shapeLayer
        self.layer.addSublayer(gradientLayer)
    }
    
    func updateAnimateProgress(_ progress: NSNumber) {
        gradientLayer.locations = [progress, progress]
    }
    
}
