//
//  IAPService.swift
//  
//
//  Created by 정진균 on 2023/05/06.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import RxSwift
import MenualEntity

public protocol IAPServiceProtocol {
    func getPaymentStateObservable() -> Observable<SKPaymentTransactionState>
    func getLocalPriceObservable(productID: String) -> Observable<String>
    func restorePurchaseObservable() -> Observable<Void>
    func purchase(productID: String) -> Observable<Void>
    func checkPurchasedProducts() -> Observable<Void>
}

public final class IAPService: IAPServiceProtocol {
    public init() {
        
    }
    
    public func getPaymentStateObservable() -> RxSwift.Observable<SKPaymentTransactionState> {
        .create { observer in
            
            SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
                for purchase in purchases {
                    switch purchase.transaction.transactionState {
                    case .purchased, .restored:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    default:
                        break
                    }
                    observer.onNext(purchase.transaction.transactionState)
                }
            }
            return Disposables.create()
        }
    }
    
    public func getLocalPriceObservable(productID: String) -> RxSwift.Observable<String> {
        .create { observer in
            SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
                if let product = result.retrievedProducts.first {
                    let priceString = product.localizedPrice ?? ""
                    observer.onNext(priceString)
                } else if let invalidProductId = result.invalidProductIDs.first {
                    observer.onError(IAPServiceError.invaildProductID(invalidProductId))
                } else {
                    observer.onError(IAPServiceError.unknown(result.error))
                }
            }
            return Disposables.create()
        }
    }
    
    public func restorePurchaseObservable() -> RxSwift.Observable<Void> {
        .create { observer in
            SwiftyStoreKit.restorePurchases(atomically: true) { results in
                if results.restoreFailedPurchases.count > 0 {
                    observer.onError(IAPServiceError.failedRestorePurchases(results.restoreFailedPurchases))
                } else if results.restoreFailedPurchases.count > 0 {
                    observer.onNext(())
                } else {
                    observer.onError(IAPServiceError.noRestorePurchases)
                }
            }
            return Disposables.create()
        }
    }
    
    public func purchase(productID: String) -> RxSwift.Observable<Void> {
        .create { observer in
            SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
                switch result {
                case .success:
                    observer.onNext(())
                
                case .deferred(let purchase):
                    print("deferred! \(purchase)")
                    
                case .error(let error):
                    switch error.code {
                    case .unknown:
                      print("Unknown error. Please contact support")
                    case .clientInvalid:
                      print("Not allowed to make the payment")
                    case .paymentCancelled:
                      observer.onError(IAPServiceError.canceledPayment)
                    case .paymentInvalid:
                      print("The purchase identifier was invalid")
                    case .paymentNotAllowed:
                      print("The device is not allowed to make the payment")
                    case .storeProductNotAvailable:
                      print("The product is not available in the current storefront")
                    case .cloudServicePermissionDenied:
                      print("Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed:
                      print("Could not connect to the network")
                    case .cloudServiceRevoked:
                      print("User has revoked permission to use this cloud service")
                    default:
                      print((error as NSError).localizedDescription)
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    public func checkPurchasedProducts() -> Observable<Void> {
        .create { observer in
            let appleValidator = AppleReceiptValidator(service: .sandbox)

            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    // 영수증 검증 성공
                    
                    // 결제 정보 추출
                    print("iapService :: receipt = \(receipt)")

                case .error(let error):
                    // 영수증 검증 실패
                    observer.onError(IAPServiceError.unknown(error))
                }
            }
            return Disposables.create()
        }
    }
}
