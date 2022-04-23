//
//  MenualSegmentationBaseViewController.swift
//  Menual
//
//  Created by 정진균 on 2022/04/23.
//

import UIKit
import Then
import SnapKit

protocol MenualSegmentationDelegate {
    func changeToIdx(index: Int)
}

class MenualSegmentationBaseViewController: UIView {

    private var buttonTitles: [String]!
    private var buttons: [UIButton] = []
    private var selectorView: UIView!
    
    var delegate: MenualSegmentationDelegate?
    
    private var _selectedIndex: Int = 0
    public var selectedIndex: Int {
        return _selectedIndex
    }
    
    lazy var stackView = UIStackView(arrangedSubviews: buttons).then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
    }
    
    var textColor: UIColor = .white
    var selectorTextColor: UIColor = Colors.tint.sub.n400
    

    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        setViews()
        updateView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setButtonTitles(buttonTitles: [String]) {
        self.buttonTitles = buttonTitles
        print("setButtonTitles! = \(buttonTitles)")
        updateView()
    }
    
    private func setViews() {
        print("setViews!")
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configStackView() {
        self.stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        setViews()
    }
    
    private func configSelectorView() {
        // StackView에 들어간 Button의 콘텐츠 사이즈를 정확하게 알기 위해서 layout 동기화
        self.layoutIfNeeded()

        // selectorView를 Temp로 미리 초기화
        selectorView = UIView(frame: CGRect(x: 0, y: 0, width: buttons[0].intrinsicContentSize.width, height: buttons[0].intrinsicContentSize.height))
        addSubview(selectorView)
        
        let yPosition = (frame.height/2) - (selectorView.frame.height/2)
        let xPosition = (buttons[0].frame.width/2) - (selectorView.frame.width/2)
        
        // 텍스트 크기와 맞게 세팅
        selectorView.frame = CGRect(x: xPosition,
                                    y: yPosition,
                                    width: buttons[0].intrinsicContentSize.width,
                                    height: buttons[0].intrinsicContentSize.height
        )
        
        // selectorView = UIView(frame: CGRect(x: 0, y: self.frame.height, width: selectorWidth, height: 2))
        selectorView.backgroundColor = Colors.grey.g800
        selectorView.layer.cornerRadius = 8
        bringSubviewToFront(stackView)
    }
    
    private func createButton() {
        buttons = [UIButton]()
        buttons.removeAll()
        subviews.forEach({$0.removeFromSuperview()})
        for buttonTitle in buttonTitles {
            let btn = UIButton(type: .system)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle(buttonTitle, for: .normal)
            btn.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
            btn.setTitleColor(textColor, for: .normal)
            buttons.append(btn)
        }
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
    }
    
    private func updateView() {
        createButton()
        configStackView()
        configSelectorView()
    }
    
    @objc
    func buttonAction(sender: UIButton) {
        for (buttonIdx, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            if btn == sender {
                _selectedIndex = selectedIndex
                
                let yPosition = (self.stackView.frame.height/2) - (selectorView.frame.height/2)
                let xPosition = (frame.width/CGFloat(buttonTitles.count) * CGFloat(buttonIdx)) + (btn.frame.width/2) - (selectorView.frame.width/2)
                print("moveTo xPos = \(xPosition), yPosition = \(yPosition)")
                
                print("stackviewframe.height = \(self.stackView.frame.height), yposition = \(yPosition)")
                
                delegate?.changeToIdx(index: buttonIdx)

                UIView.animate(withDuration: 0.3) {
                    
                    self.selectorView.frame = CGRect(x: xPosition,
                                                     y: yPosition,
                                                     width: btn.intrinsicContentSize.width,
                                                     height: btn.intrinsicContentSize.height
                    )
                }
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
    }
    
    func setIndex(index: Int) {
        buttons.forEach {
            $0.setTitleColor(textColor, for: .normal)
        }
        
        let button = buttons[index]
        _selectedIndex = index
        button.setTitleColor(selectorTextColor, for: .normal)
        
        let yPosition = (self.stackView.frame.height/2) - (selectorView.frame.height/2)
        let xPosition = (frame.width/CGFloat(buttonTitles.count) * CGFloat(index)) + (buttons[index].frame.width/2) - (selectorView.frame.width/2)

        UIView.animate(withDuration: 0.3) {
            
            self.selectorView.frame = CGRect(x: xPosition,
                                             y: yPosition,
                                             width: self.buttons[index].intrinsicContentSize.width,
                                             height: self.buttons[index].intrinsicContentSize.height
            )
        }
    }

}
