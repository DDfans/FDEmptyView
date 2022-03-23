//
//  FDEmptyView.swift
//  FDEmptyView
//
//  Created by Stephen on 2022/3/17.
//

import UIKit

public protocol FDEmptyViewLoadingViewProtool {
    func startAnimate()
}
public extension FDEmptyViewLoadingViewProtool {
    func startAnimate() {
    }
}

extension UIActivityIndicatorView: FDEmptyViewLoadingViewProtool {
    public func startAnimate() {
        startAnimating()
    }
}

public class FDEmptyView: UIView {

    let d: Void = setDefaultApperance()
    private(set) var scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.showsVerticalScrollIndicator = false
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.contentInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        if #available(iOS 11, *) {
            scrollV.contentInsetAdjustmentBehavior = .never
        }
        return scrollV
    }()
    
    private(set) var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    var loadingView: (FDEmptyViewLoadingViewProtool & UIView)! {
        didSet {
            if !loadingView.isEqual(oldValue) {
                oldValue?.removeFromSuperview()
                self.contentView.addSubview(loadingView)
            }
            self.setNeedsLayout()
        }
    }
    
    internal lazy var imageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .center
        return imgv
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = textLabelFont
        label.textColor = textLabelTextColor
        return label
    }()
    lazy var detailTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = detailTextLabelFont
        label.textColor = detailTextLabelTextColor
        return label
    }()
    lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 20, bottom: 10, right: 20)
        btn.layer.cornerRadius = self.actionButtonCornerRadius
        btn.layer.borderColor = self.actionButtonBorderColor.cgColor
        btn.layer.borderWidth = self.actionButtonBorderwidth
        btn.layer.masksToBounds = true
        btn.backgroundColor = self.actionButtonBackgroundColor;
        btn.addTarget(self, action: #selector(actionBtnAction), for: .touchUpInside)
        return btn
    }()
    
    var actionButtonTouchBlock: ((UIButton) -> Void)?
    
    // MARK: - UIAppearance
    @objc dynamic var imageViewInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc dynamic var loadingViewInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc dynamic var textLabelInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc dynamic var detailTextLabelInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc dynamic var actionButtonInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    @objc dynamic var verticalOffset: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // 字体
    @objc dynamic var textLabelFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            textLabel.font = textLabelFont
            self.setNeedsLayout()
        }
    }
    @objc dynamic var detailTextLabelFont: UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.updateDetailTextLabelWithText(detailTextLabel.text ?? "")
        }
    }
    @objc dynamic var actionButtonFont: UIFont = UIFont.systemFont(ofSize: 15) {
        didSet {
            actionButton.titleLabel?.font = actionButtonFont
            self.setNeedsLayout()
        }
    }
    // 颜色
    @objc dynamic var textLabelTextColor: UIColor = .black {
        didSet {
            textLabel.textColor = textLabelTextColor
            self.setNeedsLayout()
        }
    }
    @objc dynamic var detailTextLabelTextColor: UIColor = .darkGray {
        didSet {
            self.updateDetailTextLabelWithText(detailTextLabel.text ?? "")
        }
    }
    @objc dynamic var actionButtonTitleColor: UIColor = .black {
        didSet {
            actionButton.setTitleColor(actionButtonTitleColor, for: .normal)
        }
    }
    @objc dynamic var actionButtonBackgroundColor: UIColor = .white {
        didSet {
            actionButton.backgroundColor = actionButtonBackgroundColor
        }
    }
    @objc dynamic var actionButtonBorderColor: UIColor = .gray {
        didSet {
            actionButton.layer.borderColor = actionButtonBorderColor.cgColor
        }
    }
    @objc dynamic var actionButtonCornerRadius: CGFloat = 0 {
        didSet {
            actionButton.layer.cornerRadius = actionButtonCornerRadius
        }
    }
    @objc dynamic var actionButtonBorderwidth: CGFloat = 0 {
        didSet {
            actionButton.layer.borderWidth = actionButtonBorderwidth
        }
    }

    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        didInitialize()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        didInitialize()
    }
    
    func didInitialize() {
        self.setupDefulte()
        
        addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        let activity = UIActivityIndicatorView.init(style:.gray)
        activity.hidesWhenStopped = false
        loadingView = activity
        self.contentView.addSubview(loadingView)
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.textLabel)
        self.contentView.addSubview(self.detailTextLabel)
        self.contentView.addSubview(self.actionButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.scrollView.frame = self.bounds
        
        let contentViewSize = self.sizeThatContentViewFits()
        
        let posiY = contentViewSize.height > self.scrollView.bounds.height ? 0 : (self.bounds.height - contentViewSize.height) / 2.0
        self.contentView.frame = CGRect.init(x: 0, y: posiY, width: contentViewSize.width, height: contentViewSize.height)
        
        let maxW = fmax(self.scrollView.bounds.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right, contentViewSize.width)
        let maxH = fmax(self.scrollView.bounds.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom, contentViewSize.height)
        self.scrollView.contentSize = CGSize.init(width: maxW, height: maxH)
        
        var originY = 0.0
        if !self.loadingView.isHidden {
            var f = self.loadingView.frame;
            f.origin.x = (self.contentView.bounds.width - f.width) / 2.0 + self.loadingViewInsets.left - self.loadingViewInsets.right
            f.origin.y = originY + self.loadingViewInsets.top
            self.loadingView.frame = f
            originY = f.maxY + self.loadingViewInsets.bottom
        }
        if !self.imageView.isHidden {
            self.imageView.sizeToFit()
            var f = self.imageView.frame;
            f.origin.x = (self.contentView.bounds.width - f.width) / 2.0 + self.imageViewInsets.left - self.imageViewInsets.right
            f.origin.y = originY + self.imageViewInsets.top
            self.imageView.frame = f
            originY = f.maxY + self.imageViewInsets.bottom
        }
        if !self.loadingView.isHidden {
            var f = self.loadingView.frame;
            f.origin.x = (self.contentView.bounds.width - f.width) / 2.0 + self.loadingViewInsets.left - self.loadingViewInsets.right
            f.origin.y = originY + self.loadingViewInsets.top
            self.loadingView.frame = f
            originY = f.maxY + self.loadingViewInsets.bottom
        }
        if !self.textLabel.isHidden {
            let w = self.contentView.bounds.width - self.textLabelInsets.left - self.textLabelInsets.right
            let size = self.textLabel.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude))
            self.textLabel.frame = CGRect.init(x: self.textLabelInsets.left, y: originY+self.textLabelInsets.top, width: w, height: size.height)
            originY = self.textLabel.frame.maxY + self.textLabelInsets.bottom
        }
        if !self.detailTextLabel.isHidden {
            let w = self.contentView.bounds.width - self.detailTextLabelInsets.left - self.detailTextLabelInsets.right
            let size = self.detailTextLabel.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude))
            self.detailTextLabel.frame = CGRect.init(x: self.detailTextLabelInsets.left, y: originY+self.detailTextLabelInsets.top, width: w, height: size.height)
            originY = self.detailTextLabel.frame.maxY + self.detailTextLabelInsets.bottom
        }
        if !self.actionButton.isHidden {
            self.actionButton.sizeToFit()
            var f = self.actionButton.frame;
            f.origin.x = (self.contentView.bounds.width - f.width) / 2.0 + self.actionButtonInsets.left - self.actionButtonInsets.right
            f.origin.y = originY + self.actionButtonInsets.top
            self.actionButton.frame = f
            originY = f.maxY + self.actionButtonInsets.bottom
        }
        
    }
    
    private func sizeThatContentViewFits() -> CGSize {
        let w = self.scrollView.bounds.width - self.scrollView.contentInset.left - self.scrollView.contentInset.right
        let imgH = self.imageView.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude)).height + self.imageViewInsets.top + self.imageViewInsets.bottom
        let loadH = self.loadingView.bounds.height + self.loadingViewInsets.top + self.loadingViewInsets.bottom
        let textH = self.textLabel.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude)).height + self.textLabelInsets.top + self.textLabelInsets.bottom
        let detailH = self.detailTextLabel.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude)).height + self.detailTextLabelInsets.top + self.detailTextLabelInsets.bottom
        let btnH = self.actionButton.sizeThatFits(CGSize.init(width: w, height: CGFloat.greatestFiniteMagnitude)).height + self.actionButtonInsets.top + self.actionButtonInsets.bottom
        
        var h = 0.0;
        if !self.imageView.isHidden {
            h += imgH
        }
        if !self.loadingView.isHidden {
            h += loadH;
        }
        if !self.textLabel.isHidden {
            h += textH;
        }
        if !self.detailTextLabel.isHidden {
            h += detailH;
        }
        if !self.actionButton.isHidden {
            h += btnH;
        }
        
        return CGSize.init(width: w, height: h)
    }
    
    func setupDefulte() {
        let appearance = FDEmptyView.appearance()
        self.imageViewInsets = appearance.imageViewInsets
        self.loadingViewInsets = appearance.loadingViewInsets;
        self.textLabelInsets = appearance.textLabelInsets;
        self.detailTextLabelInsets = appearance.detailTextLabelInsets;
        self.actionButtonInsets = appearance.actionButtonInsets;
        self.verticalOffset = appearance.verticalOffset;
        
        self.actionButtonCornerRadius = appearance.actionButtonCornerRadius;
        self.actionButtonBackgroundColor = appearance.actionButtonBackgroundColor;
        self.actionButtonBorderColor = appearance.actionButtonBorderColor;
        self.actionButtonBorderwidth = appearance.actionButtonBorderwidth;
        
        self.actionButtonFont = appearance.actionButtonFont;
        self.textLabelFont = appearance.textLabelFont;
        self.detailTextLabelFont = appearance.detailTextLabelFont;
        self.textLabelTextColor = appearance.textLabelTextColor;
        self.detailTextLabelTextColor = appearance.detailTextLabelTextColor;
        self.actionButtonTitleColor = appearance.actionButtonTitleColor;

    }
    // MARK: - Action
    @objc private func actionBtnAction() {
        guard actionButtonTouchBlock != nil else {
            return
        }
        if let config = actionButtonTouchBlock {
            config(actionButton)
        }
    }
    // MARK: - Private
    private func updateDetailTextLabelWithText(_ text: String?) {
        let t: String? = text
        if t != nil {
            let style = NSMutableParagraphStyle.init()
            style.minimumLineHeight = self.detailTextLabelFont.pointSize + 10
            style.maximumLineHeight = 0
            style.lineBreakMode = .byWordWrapping
            style.alignment = .center
            let string = NSAttributedString.init(string: t!, attributes: [.font : self.detailTextLabelFont,.foregroundColor:self.detailTextLabelTextColor,.paragraphStyle:style])
            self.detailTextLabel.attributedText = string
        }
        self.detailTextLabel.isHidden = t == nil
        self.setNeedsLayout()
    }

    // MARK: - Public
    // 显示或隐藏loading图标
    open func setLoadingViewHidden(_ isHidden: Bool) {
        self.loadingView.isHidden = isHidden
        if !isHidden {
            self.loadingView.startAnimate()
        }
        self.setNeedsLayout()
    }
    /// 设置图片
    open func setImage(_ image: UIImage?) {
        self.imageView.image = image;
        self.imageView.isHidden = self.imageView.image == nil ? true : false
        self.setNeedsLayout()
    }
    /// 设置提示语
    open func setTextLabelText(_ text: String?) {
        self.textLabel.text = text
        self.textLabel.isHidden = text == nil ? true : false
        self.setNeedsLayout()
    }
    /// 设置详细提示语
    open func setDetailTextLabelText(_ text: String?) {
        self.updateDetailTextLabelWithText(text)
    }
    /// 设置操作按钮文本
    open func setActionButtonTitle(_ title: String?) {
        let t: String? = title
        self.actionButton.setTitle(t, for: .normal)
        self.actionButton.isHidden = t == nil
        self.setNeedsLayout()
    }

}

extension FDEmptyView {
    static func setDefaultApperance() -> Void {
        let appearance = FDEmptyView.appearance()
        appearance.imageViewInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 36, right: 0)
        appearance.loadingViewInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 36, right: 0)
        appearance.textLabelInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 0)
        appearance.detailTextLabelInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 10, right: 0)
        appearance.actionButtonInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        appearance.verticalOffset = -30
        
        appearance.textLabelFont = UIFont.systemFont(ofSize: 15)
        appearance.detailTextLabelFont = UIFont.systemFont(ofSize: 14)
        appearance.actionButtonFont = UIFont.systemFont(ofSize: 15)
        
        appearance.textLabelTextColor = UIColor.red;
        appearance.detailTextLabelTextColor = UIColor.gray;
        appearance.actionButtonTitleColor = UIColor.red;
        appearance.actionButtonBorderColor = UIColor.gray;
        appearance.actionButtonCornerRadius = 18
        appearance.actionButtonBorderwidth = 1
    }
}



