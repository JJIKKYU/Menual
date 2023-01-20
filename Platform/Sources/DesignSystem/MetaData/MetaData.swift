//
//  MetaData.swift
//  Menual
//
//  Created by 정진균 on 2022/11/05.
//

import Foundation
import UIKit
import SnapKit
import Then

public class MetaData: UIView {
    public enum MetaDataType {
        case writing
        case view
        case image
        case rewriting
    }
    
    public var metaDataType: MetaDataType = .writing {
        didSet { setNeedsLayout() }
    }
    
    public var date: String = "2099.99,99" {
        didSet { setNeedsLayout() }
    }
    
    public var page: String = "119" {
        didSet { setNeedsLayout() }
    }
    
    public var writingCount: String = "10" {
        didSet { setNeedsLayout() }
    }
    
    private let dateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.isHidden = true
    }
    
    private let verticalDivider = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let pageLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = Colors.grey.g600
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.isHidden = true
    }
    
    private let writingLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.text = "N자 작성"
        $0.textColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let editImageBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.modify.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let deleteBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.delete.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    private let moreBtn = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(Asset._20px.more.image.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = Colors.grey.g600
        $0.isHidden = true
    }
    
    public init(type: MetaDataType) {
        self.metaDataType = type
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(dateLabel)
        addSubview(verticalDivider)
        addSubview(pageLabel)
        addSubview(writingLabel)
        addSubview(editImageBtn)
        addSubview(deleteBtn)
        addSubview(moreBtn)
        
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        verticalDivider.snp.makeConstraints { make in
            make.leading.equalTo(dateLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(15)
            make.width.equalTo(1)
        }
        
        pageLabel.snp.makeConstraints { make in
            make.leading.equalTo(verticalDivider.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
        
        writingLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        deleteBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        editImageBtn.snp.makeConstraints { make in
            make.trailing.equalTo(deleteBtn.snp.leading).offset(-8)
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        
        moreBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        dateLabel.text = date
        pageLabel.text = "P. " + page
        writingLabel.text = "\(writingCount)자 작성"
        
        switch metaDataType {
        case .writing:
            dateLabel.isHidden = false
            verticalDivider.isHidden = false
            pageLabel.isHidden = false
            writingLabel.isHidden = false
            
        case .view:
            dateLabel.isHidden = false
            verticalDivider.isHidden = false
            pageLabel.isHidden = false
            
        case .image:
            editImageBtn.isHidden = false
            deleteBtn.isHidden = false
            
        case .rewriting:
            dateLabel.isHidden = false
            verticalDivider.isHidden = false
            pageLabel.isHidden = false
            moreBtn.isHidden = false
        }
    }
}
