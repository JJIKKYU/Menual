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
            listInfoView.infoType = .infoWriting
            
        case false:
            listInfoView.infoType = .time
        }
        
        switch imageEnabled {
        case true:
            listTitleView.listTitleType = .titlePicture
            
        case false:
            listTitleView.listTitleType = .title
        }
    }
    
    func setViews() {
        backgroundColor = .clear
        addSubview(listTitleView)
        addSubview(listInfoView)
        addSubview(delCheckBtn)
        
        listTitleView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(24)
        }

        listInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(listTitleView.snp.bottom).offset(6)
        }
        
        delCheckBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
        }
    }
}
