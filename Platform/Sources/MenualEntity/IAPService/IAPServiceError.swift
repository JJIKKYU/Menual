//
//  IAPServiceError.swift
//  
//
//  Created by 정진균 on 2023/05/06.
//

import Foundation
import StoreKit

public enum IAPServiceError: Error {
    case invaildProductID(String)
    case unknown(Error?)
    case failedRestorePurchases([(SKError, String?)])
    case noRetrievedProduct
    case noRestorePurchases
    case noProducts
    case canceledPayment
}
