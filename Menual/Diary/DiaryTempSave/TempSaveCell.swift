//
//  TempSaveCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/15.
//

import UIKit
import SnapKit
import Then

class TempSaveCell: UITableViewCell {
    
    public var title: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    public var date: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    public var page: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    public var imageEnabled: Bool = false {
        didSet {
            layoutSubviews()
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "테스트입니다"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g100
        $0.font = UIFont.AppTitle(.title_2)
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "날짜입니다"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g400
        $0.font = UIFont.AppBodyOnlyFont(.body_1)
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g400
        $0.font = UIFont.AppBodyOnlyFont(.body_1)
    }
    
    // 이건 아마 바뀔듯
    private let imageEnableView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
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
        
        titleLabel.text = title
        dateLabel.text = date
        pageLabel.text = page
        if imageEnabled {
            imageEnableView.isHidden = false
        }
    }
    
    func setViews() {
        backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(pageLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(20)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(18)
        }
        titleLabel.sizeToFit()
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.height.equalTo(13)
        }
        dateLabel.sizeToFit()
    }
}
