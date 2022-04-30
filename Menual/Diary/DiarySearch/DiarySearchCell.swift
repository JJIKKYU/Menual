//
//  DiarySearchCell.swift
//  Menual
//
//  Created by 정진균 on 2022/04/30.
//

import UIKit
import SnapKit
import Then

class DiarySearchCell: UITableViewCell {
    
    var title: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var desc: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var page: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    var createdAt: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_6)
        $0.textColor = .white
    }
    
    private let descriptionLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_1)
        $0.textColor = .white
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.textColor = .white
    }
    
    private let createdAtLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_4)
        $0.textColor = .white
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
        print("!!")
        titleLabel.text = title
        descriptionLabel.text = desc
        pageLabel.text = page
        createdAtLabel.text = createdAt
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(pageLabel)
        addSubview(createdAtLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.trailing.equalToSuperview().inset(20)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(20)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(2)
        }
        pageLabel.sizeToFit()
        
        createdAtLabel.snp.makeConstraints { make in
            make.leading.equalTo(pageLabel.snp.trailing).offset(4)
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(2)
        }
    }

}
