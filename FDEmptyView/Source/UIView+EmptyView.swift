//
//  UIView+EmptyView.swift
//  FDEmptyView
//
//  Created by Stephen on 2022/3/23.
//

import UIKit

private var emptyKey = "emptyViewKey"

extension UIView {
    
    var fd_emptyView: FDEmptyView {
        get {
            var view = objc_getAssociatedObject(self, &emptyKey)
            if view == nil {
                view = FDEmptyView.init(frame:bounds)
                objc_setAssociatedObject(self, &emptyKey, view, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return view as! FDEmptyView
        }
        set {
        }
    }
    public func fd_showEmptyView() {
        self.addSubview(self.fd_emptyView)
    }

    public func fd_hideEmptyView() {
        if self.fd_isEmptyViewShowing() {
            self.fd_emptyView.removeFromSuperview()
        }
    }
    public func fd_isEmptyViewShowing() -> Bool {
        return objc_getAssociatedObject(self, &emptyKey) != nil && self.fd_emptyView.superview != nil
    }
    
    public func fd_showEmptyViewWithLoading() {
        fd_showEmptyView()
        self.fd_emptyView.setImage(nil)
        self.fd_emptyView.setLoadingViewHidden(false)
        self.fd_emptyView.setTextLabelText(nil)
        self.fd_emptyView.setDetailTextLabelText(nil)
        self.fd_emptyView.setActionButtonTitle(nil)
    }
    func fd_showEmptyViewWith(showLoading:Bool, image:UIImage?, text:String?, detailText: String?, buttonTitle:String?, actionBlock: @escaping(UIButton) -> Void) {
        fd_showEmptyView()
        self.fd_emptyView.setLoadingViewHidden(!showLoading)
        self.fd_emptyView.setImage(image)
        self.fd_emptyView.setTextLabelText(text)
        self.fd_emptyView.setDetailTextLabelText(detailText)
        self.fd_emptyView.setActionButtonTitle(buttonTitle)
        self.fd_emptyView.actionButtonTouchBlock = actionBlock
    }
    func fd_showEmptyViewWith(text:String?, detailText: String?, buttonTitle:String?, actionBlock: @escaping(UIButton) -> Void) {
        fd_showEmptyViewWith(showLoading: false, image: nil, text: text, detailText: detailText, buttonTitle: buttonTitle, actionBlock: actionBlock)
    }
    func fd_showEmptyViewWith(image:UIImage?,text:String?, detailText: String?, buttonTitle:String?, actionBlock: @escaping(UIButton) -> Void) {
        fd_showEmptyViewWith(showLoading: false, image: image, text: text, detailText: detailText, buttonTitle: buttonTitle,actionBlock: actionBlock)
    }
    
    func fd_layoutEmptyView() {
        if objc_getAssociatedObject(self, &emptyKey) != nil {
            self.fd_emptyView.frame = bounds
        }
    }
}
