//
//  DesignSystemCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import UIKit
import Then
import SnapKit

class DesignSystemCell: UITableViewCell {
    
    var title: String = "" {
        didSet {
            setNeedsLayout()
        }
    }
    
    let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_1)
        $0.tintColor = .black
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setViews() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.text = title
    }

}
