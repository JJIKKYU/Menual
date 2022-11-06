//
//  NumberPadCell.swift
//  Menual
//
//  Created by 정진균 on 2022/11/06.
//

import UIKit
import Then
import SnapKit

class NumberPadCell: UICollectionViewCell {
    
    var number: String = "" {
        didSet { setNeedsLayout() }
    }
    
    private let numberLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont(name: UIFont.Montserrat(.ExtraBold), size: 32)
        $0.textAlignment = .center
        $0.textColor = Colors.grey.g500
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        backgroundColor = Colors.background
        addSubview(numberLabel)
        
        numberLabel.snp.makeConstraints { make in
            make.leading.width.top.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        numberLabel.text = number
    }
}
