//
//  DiaryBottomSheetRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/04/24.
//

import RIBs
import DiaryWriting

protocol DiaryBottomSheetInteractable: Interactable, DiaryWritingListener {
    var router: DiaryBottomSheetRouting? { get set }
    var listener: DiaryBottomSheetListener? { get set }
}

protocol DiaryBottomSheetViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DiaryBottomSheetRouter: ViewableRouter<DiaryBottomSheetInteractable, DiaryBottomSheetViewControllable>, DiaryBottomSheetRouting {
    
    private let diaryWritingBuildable: DiaryWritingBuildable
    private var diaryWritingRouting: Routing?

    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DiaryBottomSheetInteractable,
        viewController: DiaryBottomSheetViewControllable,
        diaryWritingBuildable: DiaryWritingBuildable
    ) {
        self.diaryWritingBuildable = diaryWritingBuildable
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
