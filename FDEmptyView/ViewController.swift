//
//  ViewController.swift
//  FDEmptyView
//
//  Created by Stephen on 2022/3/14.
//

import UIKit

class ViewController: UIViewController {
    
    enum content: String {
        case state1 = "显示Loading"
        case state2 = "显示提示语"
        case state3 = "显示提示和操作按钮"
        case state4 = "显示占位图及文字"
        case state5 = "全部显示"

    }
    var contents: [content] = [.state1,.state2,.state3,.state4,.state5]
    var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self;
            tableView.tableFooterView = UIView()
        }
    }
    
    lazy var tap: UITapGestureRecognizer = {
        let t = UITapGestureRecognizer.init(target: self, action: #selector(reload))
        return t
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView.init(frame: view.bounds, style: .plain)
        self.view.addSubview(tableView)
        view.fd_emptyView.addGestureRecognizer(self.tap)
        view.fd_emptyView.actionButtonBorderColor = .red
        view.fd_emptyView.actionButtonBorderwidth = 1
        view.fd_emptyView.actionButtonCornerRadius = 8
        view.fd_emptyView.actionButtonInsets = UIEdgeInsets.init(top: 40, left: 0, bottom: 0, right: 0)
    }

    
    @objc func reload() {
        view.fd_hideEmptyView()
        self.tableView.reloadData()
        tap.isEnabled = true
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return view.fd_emptyView.superview == nil ? contents.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = contents[indexPath.row].rawValue
        
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch contents[indexPath.row] {
        case .state1:
            view.fd_showEmptyViewWithLoading()
        case .state2:
            view.fd_showEmptyViewWith(text: "请求失败", detailText: "请检查网络连接", buttonTitle: nil) { btn in
                
            }
        case .state3:
            view.fd_showEmptyViewWith(text: "请求失败", detailText: "请检查网络连接", buttonTitle: "重试") {[weak self] btn in
                self?.reload()
            }
            tap.isEnabled = false
        case .state4:
            view.fd_showEmptyViewWith(image: UIImage.init(named: "empty_nonet"), text: nil, detailText: "请检查网络连接", buttonTitle: nil) { btn in
                
            }
        case .state5:
            view.fd_showEmptyViewWith(image: UIImage.init(named: "empty_nonet"), text: "请求失败", detailText: "请检查网络连接", buttonTitle: "重试") {[weak self] btn in
                self?.reload()
            }
            tap.isEnabled = false
        }
        tableView.reloadData()
    }
    
}
