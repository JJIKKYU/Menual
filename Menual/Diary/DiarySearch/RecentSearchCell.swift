//
//  RecentSearchCell.swift
//  Menual
//
//  Created by 정진균 on 2022/04/30.
//

import Foundation
import UIKit
import Then
import SnapKit
import DesignSystem

class RecentSearchCell: UITableViewCell {
    
    var keyword: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var createdAt: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    
    private let keywordLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_6)
        $0.textColor = .white
    }
    
    private let createdAtLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.textColor = .white
    }
    
    lazy var deleteBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.close.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.contentMode = .scaleAspectFit
        $0.contentHorizontalAlignment = .fill
        $0.contentVerticalAlignment = .fill
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        keywordLabel.text = keyword
        createdAtLabel.text = createdAt
    }
    
    func setViews() {
        addSubview(keywordLabel)
        addSubview(createdAtLabel)
        addSubview(deleteBtn)
        
        keywordLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(12)
        }
        keywordLabel.sizeToFit()
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(20)
        }
        
        createdAtLabel.snp.makeConstraints { make in
            make.trailing.equalTo(deleteBtn.snp.leading).inset(20)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        createdAtLabel.sizeToFit()
    }

}
