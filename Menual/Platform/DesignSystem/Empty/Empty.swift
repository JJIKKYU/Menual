//
//  Empty.swift
//  Menual
//
//  Created by 정진균 on 2022/10/16.
//

import UIKit
import Then
import SnapKit

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
        $0.text = "아직 작성한 메뉴얼이 없어요"
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
            make.centerX.centerY.equalToSuperview()
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
                emptyImageTitleLabel.text = "아직 작성한 메뉴얼이 없어요"
                
            case .filter:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = "필터에 해당하는 메뉴얼이 없어요"

            }

            
        case .writing:
            guard let writingType = writingType else {
                return
            }
            switch writingType {
            case .temporarysave:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = "임시저장된 글이 없어요"

            case .lock:
                emptyImageView.image = Asset.Illurstration.viewLock.image
                emptyImageTitleLabel.text = "숨긴 일기에요"
            }
            
            
        case .search:
            guard let searchType = searchType else {
                return
            }
            switch searchType {
            case .search:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = "내가 작성한 메뉴얼을 찾아보세요"
                
            case .result:
                emptyImageView.image = Asset.Illurstration.emtpySpace.image
                emptyImageTitleLabel.text = "일치하는 메뉴얼이 없어요"
            }

        }
    }

}
