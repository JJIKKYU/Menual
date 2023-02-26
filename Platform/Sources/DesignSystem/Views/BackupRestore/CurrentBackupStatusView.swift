//
//  CurrentBackupStatusView.swift
//  
//
//  Created by 정진균 on 2023/02/26.
//

import UIKit
import SnapKit
import Then
import MenualEntity
import MenualUtil

public class CurrentBackupStatusView: UIView {
    
    public enum StatusType {
        case backup
        case restore
    }
    
    public var statusType: StatusType = .backup {
        didSet { setNeedsLayout() }
    }
    
    public var backupHistoryModelRealm: BackupHistoryModelRealm? {
        didSet { setNeedsLayout() }
    }
    
    /// 백업 결과가 있냐 없냐..
    public var isVaildBackupStatus: Bool = false {
        didSet { setNeedsLayout() }
    }
    
    /// restore에서 사용
    public var fileName: String? {
        didSet { setNeedsLayout() }
    }
    
    public var fileCreatedAt: String? {
        didSet { setNeedsLayout() }
    }

    private let currentBackupStackView = UIStackView(frame: .zero)
    
    private let currentBackupDateStackView = UIStackView(frame: .zero)
    private let currentBackupDate = UILabel(frame: .zero)
    private let currentBackupDateDesc = UILabel(frame: .zero)
    
    private let currentBackupDiarycountStackView = UIStackView(frame: .zero)
    private let currentBackupDiarycount = UILabel(frame: .zero)
    private let currentBackupDiarycountDesc = UILabel(frame: .zero)
    
    private let currentBackupPageStackView = UIStackView(frame: .zero)
    private let currentBackupPage = UILabel(frame: .zero)
    private let currentBackupPageDesc = UILabel(frame: .zero)
    
    private let backupInformationLabel = UILabel(frame: .zero)
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(type: StatusType) {
        self.statusType = type
        super.init(frame: .zero)
        setViews()
    }
    
    func setViews() {
        addSubview(currentBackupStackView)
        currentBackupStackView.addArrangedSubview(currentBackupDateStackView)
        currentBackupDateStackView.addArrangedSubview(currentBackupDate)
        currentBackupDateStackView.addArrangedSubview(currentBackupDateDesc)
        
        currentBackupStackView.addArrangedSubview(currentBackupDiarycountStackView)
        currentBackupDiarycountStackView.addArrangedSubview(currentBackupDiarycount)
        currentBackupDiarycountStackView.addArrangedSubview(currentBackupDiarycountDesc)
        
        currentBackupStackView.addArrangedSubview(currentBackupPageStackView)
        currentBackupPageStackView.addArrangedSubview(currentBackupPage)
        currentBackupPageStackView.addArrangedSubview(currentBackupPageDesc)
        
        currentBackupStackView.addArrangedSubview(backupInformationLabel)

        currentBackupStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Colors.grey.g800
            $0.alignment = .fill
            $0.axis = .vertical
            $0.spacing = 8
            $0.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
            $0.isLayoutMarginsRelativeArrangement = true
            $0.AppCorner(._4pt)
        }
        currentBackupDateStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        currentBackupDate.do {
            $0.text = "백업한 날짜"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
        }
        currentBackupDateDesc.do {
            $0.text = "DD:DD:DD:DD"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
            $0.textAlignment = .right
        }
        
        currentBackupDiarycountStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        currentBackupDiarycount.do {
            $0.text = "백업한 메뉴얼 개수"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
        }
        currentBackupDiarycountDesc.do {
            $0.text = "120개"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
            $0.textAlignment = .right
        }
        
        currentBackupPageStackView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.distribution = .fill
        }
        currentBackupPage.do {
            $0.text = "마지막 메뉴얼 페이지"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
        }
        currentBackupPageDesc.do {
            $0.text = "P.123"
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.textColor = Colors.grey.g400
            $0.textAlignment = .right
        }
        
        backupInformationLabel.do {
            $0.numberOfLines = 0
            $0.textAlignment = .center
            $0.text =
            """
            메뉴얼을 백업하시면
            이곳에 백업한 메뉴얼 정보가 표시돼요.
            """
            $0.setLineHeight(lineHeight: 1.34)
            $0.textColor = Colors.grey.g400
            $0.font = UIFont.AppBodyOnlyFont(.body_2)
            $0.isHidden = true
        }
        
        currentBackupStackView.snp.makeConstraints { make in
            make.leading.top.width.bottom.equalToSuperview()
        }
        currentBackupDate.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        currentBackupPage.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        currentBackupDiarycount.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        backupInformationLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        switch statusType {
        case .backup:
            switch isVaildBackupStatus {
            case true:
                guard let backupHistoryModelRealm = backupHistoryModelRealm else { return }
                currentBackupStackView.do {
                    $0.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
                }

                currentBackupPageStackView.isHidden = false
                currentBackupPageDesc.text = String(backupHistoryModelRealm.pageCount)
                currentBackupDiarycountStackView.isHidden = false
                currentBackupDiarycountDesc.text = String(backupHistoryModelRealm.diaryCount)
                currentBackupDateStackView.isHidden = false
                currentBackupDateDesc.text = String(backupHistoryModelRealm.createdAt.toStringWithHourMin())
                backupInformationLabel.isHidden = true
            case false:
                
                currentBackupStackView.do {
                    $0.layoutMargins = UIEdgeInsets(top: 12, left: 20, bottom: 16, right: 20)
                }

                currentBackupPageStackView.isHidden = true
                currentBackupDiarycountStackView.isHidden = true
                currentBackupDateStackView.isHidden = true
                backupInformationLabel.isHidden = false
            }
            break

        case .restore:
            guard let fileName,
                  let fileCreatedAt else { return }
            
            currentBackupStackView.do {
                $0.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
            }

            currentBackupPageStackView.isHidden = false
            currentBackupPage.text = "파일명"
            currentBackupPageDesc.text = fileName
            currentBackupDiarycountStackView.isHidden = false
            currentBackupDiarycount.text = "생성일"
            currentBackupDiarycountDesc.text = fileCreatedAt
            currentBackupDateStackView.isHidden = true
            backupInformationLabel.isHidden = true
            
            break
        }
    }

}
