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
        currentPageIndicatorTintColor = Colors.grey.g600
        pageIndicatorTintColor = Colors.grey.g600
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateDots() {
        for index in 0..<numberOfPages {
            print("index = \(index)")
            setIndicatorImage(Asset.Pagination.paginationUnselected.image.withRenderingMode(.alwaysTemplate), forPage: index)
            if index == currentPage {
                print("currentPage! = \(index)")
                setIndicatorImage(Asset.Pagination.paginationSelected.image.withRenderingMode(.alwaysTemplate), forPage: index)
            }
        }
    }
}
