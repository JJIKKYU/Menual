//
//  MomentsNoStartView.swift
//  Menual
//
//  Created by 정진균 on 2023/01/05.
//

import SnapKit
import Then
import UIKit

public class MomentsNoStartView: UIView {
    
    let maxCount: Int = 14
    
    let testSet: [Int: String] = [
        1: "12/31",
        2: "01/01",
        3: "01/02",
        4: "01/05",
        5: "01/09",
        6: "01/12",
        7: "01/15",
        8: "01/17",
        9: "01/19",
        10: "01/21",
    ]
    
    // 작성한 메뉴얼 개수를 넣으면 활성화
    public var writingDiarySet: [Int: String] = [
        1: "12/31",
        2: "01/01",
        3: "01/02",
        4: "01/05",
        5: "01/09",
        6: "01/12",
        7: "01/15",
        8: "01/17",
        9: "01/19",
        10: "01/21",
    ] {
        didSet { setNeedsLayout() }
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont.AppTitle(.title_4)
        $0.text = "메뉴얼은 당신을 알아가는 중!"
        $0.textColor = Colors.grey.g100
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let subTitleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = " "
        $0.setLineHeight(lineHeight: 1.28)
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = Colors.grey.g400
    }
        
    let circleView = MomentsNoStartCircleView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.value = 0.84
    }
    
    private let imageView = UIImageView().then {
        $0.image = Asset._40px.paper.image
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private let countLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "1/14"
        $0.font = UIFont.AppHead(.head_1)
        $0.textColor = Colors.grey.g600
    }
    
    private let stampView = MomentsNoStartStampView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        setViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setViews() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(circleView)
        addSubview(stampView)
        
        addSubview(imageView)
        addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        circleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(80)
            make.top.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(circleView.snp.top).offset(14)
            make.width.height.equalTo(40)
            make.centerX.equalTo(circleView.snp.centerX)
        }
        
        countLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom)
            make.centerX.equalTo(circleView.snp.centerX)
        }
        
        stampView.snp.makeConstraints { make in
            make.top.equalTo(subTitleLabel.snp.bottom).offset(22)
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 작성을 모두 완료했을때
        if writingDiarySet.count >= maxCount {
            titleLabel.text = "일기 작성을 완료했어요!"
            subTitleLabel.text = "내일이면 나를 알아갈 수 있는\n새로운 콘텐츠가 제공될 거예요! :D"
        } else {
            titleLabel.text = "메뉴얼은 당신을 알아가는 중!"
            subTitleLabel.text = "\(maxCount)개의 일기를 적어보세요.\n나를 알아갈 수 있는 콘텐츠가 제공돼요 :)"
        }
        circleView.value = (Double(writingDiarySet.count) * Double(1.0 / Double(maxCount)))
        circleView.count = writingDiarySet.count
        countLabel.text = "\(writingDiarySet.count)/\(maxCount)"
        stampView.writingDiarySet = writingDiarySet
    }
}
