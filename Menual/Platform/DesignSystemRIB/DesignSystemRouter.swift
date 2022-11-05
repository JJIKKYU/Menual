//
//  DesignSystemRouter.swift
//  Menual
//
//  Created by 정진균 on 2022/05/21.
//

import RIBs

protocol DesignSystemInteractable: Interactable, BoxButtonListener, GNBHeaderListener, ListHeaderListener, MomentsListener, DividerListener, CapsuleButtonListener, ListListener, FABListener, TabsListener, PaginationListener, EmptyViewListener, MetaDataListener {
    var router: DesignSystemRouting? { get set }
    var listener: DesignSystemListener? { get set }
}

protocol DesignSystemViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class DesignSystemRouter: ViewableRouter<DesignSystemInteractable, DesignSystemViewControllable>, DesignSystemRouting {

    private let boxButtonBuildable: BoxButtonBuildable
    private var boxButtonRouting: Routing?
    
    private let gnbHeaderBuildable: GNBHeaderBuildable
    private var gnbHeaderRouting: Routing?
    
    private let listHeaderBuildable: ListHeaderBuildable
    private var listHeaderRouting: Routing?
    
    private let momentsBuildable: MomentsBuildable
    private var momentsRouting: Routing?
    
    private let dividerBuildable: DividerBuildable
    private var dividerRouting: Routing?
    
    private let capsuleButtonBuildable: CapsuleButtonBuildable
    private var capsuleButtonRouting: Routing?
    
    private let listBuildable: ListBuildable
    private var listRouting: Routing?
    
    private let fabBuildable: FABBuildable
    private var fabRouting: Routing?
    
    private let tabsBuildable: TabsBuildable
    private var tabsRouting: Routing?
    
    private let paginationBuildable: PaginationBuildable
    private var paginationRouting: Routing?
    
    private let emptyBuildable: EmptyViewBuildable
    private var emptyRouting: Routing?
    
    private let metaDataBuildable: MetaDataBuildable
    private var metaDataRouting: Routing?
    
    // TODO: Constructor inject child builder protocols to allow building children.
    init(
        interactor: DesignSystemInteractable,
        viewController: DesignSystemViewControllable,
        boxButtonBuildable: BoxButtonBuildable,
        gnbHeaderBuildable: GNBHeaderBuildable,
        listHeaderBuildable: ListHeaderBuildable,
        momentsBuildable: MomentsBuildable,
        dividerBuildable: DividerBuildable,
        capsuleButtonBuildable: CapsuleButtonBuildable,
        listBuildable: ListBuildable,
        fabBuildable: FABBuildable,
        tabsBuildable: TabsBuildable,
        paginationBuildable: PaginationBuildable,
        emptyBuildable: EmptyViewBuildable,
        metaDataBuildable: MetaDataBuildable
    ) {
        self.boxButtonBuildable = boxButtonBuildable
        self.gnbHeaderBuildable = gnbHeaderBuildable
        self.listHeaderBuildable = listHeaderBuildable
        self.momentsBuildable = momentsBuildable
        self.dividerBuildable = dividerBuildable
        self.capsuleButtonBuildable = capsuleButtonBuildable
        self.listBuildable = listBuildable
        self.fabBuildable = fabBuildable
        self.tabsBuildable = tabsBuildable
        self.paginationBuildable = paginationBuildable
        self.emptyBuildable = emptyBuildable
        self.metaDataBuildable = metaDataBuildable
        super.init(interactor: interactor,
                   viewController: viewController
        )
        interactor.router = self
    }
    
    // MARK: - Box Button DesignSystem RIBs
    func attachBoxButtonVC() {
        if boxButtonRouting != nil {
            return
        }
        
        let router = boxButtonBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        boxButtonRouting = router
        attachChild(router)
    }
    
    func detachBoxButtonVC(isOnlyDetach: Bool) {
        guard let router = boxButtonRouting else {
            return
        }

        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }

        detachChild(router)
        boxButtonRouting = nil
    }
    
    // MARK: - GNB Header DesignSystem RIBs
    func attachGnbHeaderVC() {
        if gnbHeaderRouting != nil {
            return
        }
        
        let router = gnbHeaderBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        gnbHeaderRouting = router
        attachChild(router)
    }
    
    func detachGnbHeaderVC(isOnlyDetach: Bool) {
        guard let router = gnbHeaderRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        gnbHeaderRouting = nil
    }
    
    // MARK: - List Header DesignSystem RIBs
    func attachListHeaderVC() {
        if listHeaderRouting != nil {
            return
        }
        
        let router = listHeaderBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        listHeaderRouting = router
        attachChild(router)
    }
    
    func detachListHeaderVC(isOnlyDetach: Bool) {
        guard let router = listHeaderRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        listHeaderRouting = nil
    }
    
    // MARK: - Moments DesignSystem RIBs
    func attachMomentsVC() {
        if momentsRouting != nil {
            return
        }
        
        let router = momentsBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        momentsRouting = router
        attachChild(router)
    }
    
    func detachMomentsVC(isOnlyDetach: Bool) {
        guard let router = momentsRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        momentsRouting = nil
    }
    
    // MARK: - Divider DesignSystem RIBs
    func attachDividerVC() {
        if dividerRouting != nil {
            return
        }
        
        let router = dividerBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        dividerRouting = router
        attachChild(router)
    }
    
    func detachDividerVC(isOnlyDetach: Bool) {
        guard let router = dividerRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        dividerRouting = nil
    }
    
    // MARK: - Capsule Button DesignSystem RIBs
    func attachCapsuleButtonVC() {
        if capsuleButtonRouting != nil {
            return
        }
        
        let router = capsuleButtonBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        capsuleButtonRouting = router
        attachChild(router)
    }
    
    func detachCapsuleButtonVC(isOnlyDetach: Bool) {
        guard let router = capsuleButtonRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        capsuleButtonRouting = nil
    }
    
    // MARK: - List DesignSystem RIBs
    func attachListVC() {
        if listRouting != nil {
            return
        }
        
        let router = listBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        listRouting = router
        attachChild(router)
    }
    
    func detachListVC(isOnlyDetach: Bool) {
        guard let router = listRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        listRouting = nil
    }
    
    // MARK: - FAB DesignSystem RIBs
    func attachFABVC() {
        if fabRouting != nil {
            return
        }
        
        let router = fabBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        fabRouting = router
        attachChild(router)
    }
    
    func detachFABVC(isOnlyDetach: Bool) {
        guard let router = fabRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        fabRouting = nil
    }
    
    // MARK: - Tabs DesignSystem RIBs
    func attachTabsVC() {
        if tabsRouting != nil {
            return
        }
        
        let router = tabsBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        tabsRouting = router
        attachChild(router)
    }
    
    func detachTabsVC(isOnlyDetach: Bool) {
        guard let router = tabsRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        tabsRouting = nil
    }
    
    // MARK: - Pagination DesignSystem RIBs
    func attachPaginationVC() {
        if paginationRouting != nil {
            return
        }
        
        let router = paginationBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        paginationRouting = router
        attachChild(router)
    }
    
    func detachPaginationVC(isOnlyDetach: Bool) {
        guard let router = paginationRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        paginationRouting = nil
    }
    
    // MARK: - EmptyView
    func attachEmptyVC() {
        if emptyRouting != nil {
            return
        }
        
        let router = emptyBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        emptyRouting = router
        attachChild(router)
    }
    
    func detachEmptyVC(isOnlyDetach: Bool) {
        guard let router = emptyRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        emptyRouting = nil
    }
    
    // MARK: - MetaData
    func attachMetaDataVC() {
        if metaDataRouting != nil {
            return
        }
        
        let router = metaDataBuildable.build(withListener: interactor)
        viewController.pushViewController(router.viewControllable, animated: true)
        
        metaDataRouting = router
        attachChild(router)
    }
    
    func detachMetaDataVC(isOnlyDetach: Bool) {
        guard let router = metaDataRouting else {
            return
        }
        
        if !isOnlyDetach {
            viewController.popViewController(animated: true)
        }
        
        detachChild(router)
        metaDataRouting = nil
    }
}
