//
//  MyMenualCell.swift
//  Menual
//
//  Created by 정진균 on 2022/04/10.
//

import UIKit
import SnapKit
import Then

class MyMenualCell: UITableViewCell {
    
    var title = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppTitle(.title_4)
        $0.textColor = .white
        $0.text = "안녕하세요"
    }
    
    var subTitle = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_1)
        $0.text = "반갑습니다"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(title)
        addSubview(subTitle)
        
        title.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(16)
        }
        
        subTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.width.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(3)
        }
    }
}
