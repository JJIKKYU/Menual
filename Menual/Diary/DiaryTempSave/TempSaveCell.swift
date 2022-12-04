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
        didSet { setNeedsLayout() }
    }
    
    public var time: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var date: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var imageEnabled: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isWriting: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isDeleteMode: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    public var isDeleteSelected: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    var listStatus: ListStatus = .default_ {
        didSet { setNeedsLayout() }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        listStatus = highlighted ? .highlighed : .default_
    }
    
    private let listTitleView = ListTitleView(type: .title).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let listInfoView = ListInfoView(type: .info).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let delCheckBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._24px.Circle.Check.unactive.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.setImage(Asset._24px.Circle.Check.active.image.withRenderingMode(.alwaysTemplate), for: .selected)
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
        
        listTitleView.titleText = title
        listInfoView.date = date
        listInfoView.time = time

        print("TempSave :: Cell isDeleteSelected = \(isDeleteSelected)")
        
        switch isDeleteMode {
        case true:
            delCheckBtn.isHidden = false
            delCheckBtn.isSelected = isDeleteSelected
            if isDeleteSelected {
                delCheckBtn.tintColor = Colors.tint.sub.n400
            } else {
                delCheckBtn.tintColor = Colors.grey.g200
            }

        case false:
            delCheckBtn.isSelected = false
            delCheckBtn.isHidden = true
        }
        
        switch isWriting {
        case true:
            listInfoView.infoType = .timeWriting
            
        case false:
            print("TempSave :: listInfoView.infoType에 .time을 대입했습니다.")
            listInfoView.infoType = .time
        }
        
        switch imageEnabled {
        case true:
            listTitleView.listTitleType = .titlePicture
            
        case false:
            listTitleView.listTitleType = .title
        }
        
        switch listStatus {
        case .default_:
            contentView.backgroundColor = Colors.background
        case .pressed:
            contentView.backgroundColor = Colors.grey.g700
        case .highlighed:
            contentView.backgroundColor = Colors.grey.g800
        }
        print("TempSave :: listStatus = \(listStatus)")
    }
    
    func setViews() {
        contentView.addSubview(listTitleView)
        contentView.addSubview(listInfoView)
        contentView.addSubview(delCheckBtn)
        
        listTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(24)
        }

        listInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleView.snp.bottom).offset(6)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(15)
        }
        
        delCheckBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
    }
}
