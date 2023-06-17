//
//  File.swift
//  
//
//  Created by 정진균 on 2023/05/20.
//

import UIKit
import Then
import SnapKit
import MenualUtil
import MenualEntity
import GoogleMobileAds

public class ADListView: GADNativeAdView {
    
    public var title: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var body: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var adText: String = "" {
        didSet { setNeedsLayout() }
    }
    
    public var image: UIImage? {
        didSet { setNeedsLayout() }
    }
    
    private let listTitleView = ListTitleView(type: .title).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let menualImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
        $0.AppCorner(._2pt)
        $0.isHidden = false
    }
    
    private let listAdView = ListInfoAdView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = false
    }
    
    public let listBodyView = ListTitleView(type: .adTitleBodyText).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = false
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
        
        bodyView = listBodyView
        headlineView = listTitleView
        iconView = menualImageView
        advertiserView = listAdView
        nativeAd = nativeAd
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    
        // 이미지가 있을 경우 layout 변경
        if let image = image {
            self.menualImageView.image = image
            
            listTitleView.snp.updateConstraints { make in
                make.width.equalToSuperview().inset(54)
            }
            
            listBodyView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().inset(54)
            }
            
            listAdView.snp.updateConstraints { make in
                make.width.equalToSuperview().inset(54)
            }
        }
        
        listTitleView.titleText = title
        listBodyView.bodyText = body
        listAdView.adText = adText
    }
    
    func setViews() {
        backgroundColor = .clear
        
        addSubview(listTitleView)
        addSubview(menualImageView)
        addSubview(listBodyView)
        addSubview(listAdView)

        menualImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(48)
        }

        listTitleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(18)
        }
        
        listBodyView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
            make.top.equalTo(listTitleView.snp.bottom).offset(6)
            make.height.equalTo(18)
        }
        
        listAdView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(listBodyView.snp.bottom).offset(10)
            make.width.equalToSuperview().inset(20)
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }
}
