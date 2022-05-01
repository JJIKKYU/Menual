//
//  WeatherPlaceHistoryCell.swift
//  Menual
//
//  Created by 정진균 on 2022/05/01.
//

import UIKit
import SnapKit
import Then

class WeatherPlaceHistoryCell: UITableViewCell {
    
    var weatherType: Weather? = nil {
        didSet {
            layoutSubviews()
        }
    }
    
    var placeType: Place? = nil {
        didSet {
            layoutSubviews()
        }
    }
    
    var title: String = "" {
        didSet {
            layoutSubviews()
        }
    }
    
    private let iconimageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = Asset._20px.place.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .white
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.AppBodyOnlyFont(.body_2)
        $0.textColor = .white
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setViews()
        print("여기 셀")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setViews() {
        addSubview(iconimageView)
        addSubview(titleLabel)
        
        iconimageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconimageView.snp.trailing).offset(15)
            make.top.equalToSuperview().offset(16)
        }
        titleLabel.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        typeCheckAndSetIconImageView()
        titleLabel.text = title
    }
    
    func typeCheckAndSetIconImageView() {
        if let weatherType = weatherType {
            switch weatherType {
            case .sun:
                iconimageView.image = Asset._20px.Weather.sun.image.withRenderingMode(.alwaysTemplate)
            case .cloud:
                iconimageView.image = Asset._20px.Weather.cloud.image.withRenderingMode(.alwaysTemplate)
            case .rain:
                iconimageView.image = Asset._20px.Weather.rain.image.withRenderingMode(.alwaysTemplate)
            case .snow:
                iconimageView.image = Asset._20px.Weather.snow.image.withRenderingMode(.alwaysTemplate)
            case .thunder:
                iconimageView.image = Asset._20px.Weather.thunder.image.withRenderingMode(.alwaysTemplate)
            }
        }
        
        if let placeType = placeType {
            switch placeType {
            case .place:
                iconimageView.image = Asset._20px.place.image.withRenderingMode(.alwaysTemplate)
            case .car:
                iconimageView.image = Asset._20px.Place.car.image.withRenderingMode(.alwaysTemplate)
            case .company:
                iconimageView.image = Asset._20px.Place.company.image.withRenderingMode(.alwaysTemplate)
            case .home:
                iconimageView.image = Asset._20px.Place.home.image.withRenderingMode(.alwaysTemplate)
            case .school:
                iconimageView.image = Asset._20px.Place.school.image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
