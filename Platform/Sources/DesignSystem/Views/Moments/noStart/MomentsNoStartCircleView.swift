//
//  MomentsNoStartCircleView.swift
//  Menual
//
//  Created by 정진균 on 2023/01/05.
//

import UIKit
import Then
import SnapKit

class MomentsNoStartCircleView: UIView {

    let lineWidth: Double = 4
    var value: Double? {
        didSet {
            guard let _ = value else { return }
            setProgress(self.bounds)
        }
    }
    
    var count: Int = 0 {
        didSet { setNeedsLayout() }
    }
    
    private let imageView = UIImageView().then {
        $0.image = Asset._40px.paper.image
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let countLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "1/14"
        $0.font = UIFont.AppHead(.head_1)
        $0.textColor = Colors.grey.g600
    }

    init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = .clear
        
        addSubview(imageView)
        addSubview(countLabel)
        
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.text = "\(count)/14"
    }

    override func draw(_ rect: CGRect) {
        setViews()
        let bezierPath = UIBezierPath()

        bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX - ((lineWidth - 1) / 2), startAngle: 0, endAngle: .pi * 2, clockwise: true)

        bezierPath.lineWidth = 4
        Colors.grey.g800.set()
        bezierPath.stroke()
    }
    
    func setProgress(_ rect: CGRect) {
        print("Moments :: setProgress! = \(rect)")
        guard let value = self.value else {
            return
        }

        // TableView나 CollectionView에서 재생성 될때 계속 추가되는 것을 막기 위해 제거
        self.subviews.forEach { $0.removeFromSuperview() }
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let bezierPath = UIBezierPath()

        bezierPath.addArc(withCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.midX - ((lineWidth - 1) / 2), startAngle: -.pi / 2, endAngle: ((.pi * 2) * value) - (.pi / 2), clockwise: true)

        let shapeLayer = CAShapeLayer()

        shapeLayer.path = bezierPath.cgPath
        // shapeLayer.lineCap = .round    // 프로그래스 바의 끝을 둥글게 설정

        let color = Colors.tint.sub.n400

        shapeLayer.strokeColor = color.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth

        self.layer.addSublayer(shapeLayer)
    }
}
