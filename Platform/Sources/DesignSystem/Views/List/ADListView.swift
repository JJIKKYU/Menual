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
    
    private let listTitleView = ListTitleView(type: .title).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .red
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setViews() {
        
        addSubview(listTitleView)
        
        listTitleView.snp.makeConstraints { make in
            make.leading.top.bottom.width.equalToSuperview()
        }
    }
}
