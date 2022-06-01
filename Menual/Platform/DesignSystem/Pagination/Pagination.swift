//
//  Pagination.swift
//  Menual
//
//  Created by 정진균 on 2022/06/01.
//

import UIKit
import Then
import SnapKit

class Pagination: UIPageControl {
    override var currentPage: Int {
        didSet { updateDots() }
    }
    
    override var numberOfPages: Int {
        didSet { updateDots() }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDots() {
        print("updateDots!")
        
        for index in 0..<numberOfPages {
            print("index = \(index)")
            setIndicatorImage(Asset.Pagination.paginationUnselected.image, forPage: index)
            if index == currentPage {
                print("currentPage! = \(index)")
                setIndicatorImage(Asset.Pagination.paginationSelected.image, forPage: index)
            }
        }
    }
}
