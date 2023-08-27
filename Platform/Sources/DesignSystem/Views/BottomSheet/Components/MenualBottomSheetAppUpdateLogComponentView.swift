//
//  MenualBottomSheetAppUpdateLogComponentView.swift
//  
//
//  Created by 정진균 on 2023/08/27.
//

import Foundation

// MARK: - AppUpdateLogComponentDelegate

public protocol AppUpdateLogComponentDelegate: AnyObject {

}

// MARK: - MenualBottomSheetAppUpdateLogComponentView

public final class MenualBottomSheetAppUpdateLogComponentView: UIView {
    public weak var delegate: AppUpdateLogComponentDelegate?
}
