//
//  Empty.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import UIKit
import Then
import SnapKit
import MenualUtil

class Empty: UIView {
    
    enum screen {
        case main
        case writing
        case search
    }
    
    enum main {
        case main
        case filter
    }
    
    enum writing {
        case temporarysave
        case lock
    }
    
    enum search {
        case search
        case result
    }
    
    public var screenType: screen = .main {
        didSet { setNeedsLayout() }
    }
    
    public var mainType: main? {
        didSet { setNeedsLayout() }
    }
    
    public var writingType: writing? {
        didSet { setNeedsLayout() }
    }
    
    public var searchType: search? {
        didSet { setNeedsLayout() }
    }
    
    private let emptyImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    private let emptyImageTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "아직 작성한 메뉴얼이 없어요."
        $0.font = UIFont.AppTitle(.title_3)
        $0.textColor = Colors.grey.g600
    }

    init() {
        super.init(frame: CGRect.zero)
        backgroundColor = .clear
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(emptyImageView)
        addSubview(emptyImageTitleLabel)
        
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
        }
        
        emptyImageTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom)
            make.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch screenType {
        case .main:
            guard let mainType = mainType else {
                return
            }
            switch mainType {
            case .main:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = MenualString.home_desc_nonexistent_writing_menual
                
            case .filter:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = MenualString.home_desc_nonexistent_fiflter_menual

            }

            
        case .writing:
            guard let writingType = writingType else {
                return
            }
            switch writingType {
            case .temporarysave:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = MenualString.tempsave_desc_nonexistent

            case .lock:
                emptyImageView.image = Asset.Illurstration.viewLock.image
                emptyImageTitleLabel.text = MenualString.detail_desc_lock
            }
            
            
        case .search:
            guard let searchType = searchType else {
                return
            }
            switch searchType {
            case .search:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = MenualString.search_desc_find_menual
                
            case .result:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = MenualString.search_desc_inconsistent
            }

        }
    }

}
