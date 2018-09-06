//
//  HomeSubViewController.swift
//  MultiTabDeo
//
//  Created by 演兽 on 2018/9/5.
//  Copyright © 2018年 演兽. All rights reserved.
//

import UIKit
import MJRefresh
class HomeSubViewController: UIViewController {

    weak var scrollDelgate: SubScrollCallBack?
    var sub_contentInset: CGFloat = 0
    var endRefreshBlock: ((_ view: UIScrollView?) -> Void)?

    @IBOutlet weak var tableview: UITableView!
    var numCount: Int = 0
    
    static func instantVC() -> HomeSubViewController {
        let vc = HomeSubViewController(nibName: "HomeSubViewController", bundle: nil)
        return vc 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        tableview.tableFooterView = UIView()
        tableview.contentInset = UIEdgeInsetsMake(sub_contentInset, 0, 0, 0)
        
        if #available(iOS 11.0, *) {
            tableview.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        tableview.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(startRefresh))
        tableview.mj_header.isHidden = true
        self.tableview.reloadData()
        //TODO: 初始化不直接调tableview.mj_header.beginrefresh()
        startRequest()
    }
    
    func startRequest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.tableview.mj_header.isHidden = false
            self.numCount = 20
            self.tableview.reloadData()
            self.tableview.layoutIfNeeded()
            self.endRefreshBlock?(self.tableview)
        }
    }

    @objc func startRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tableview.mj_header.endRefreshing()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension HomeSubViewController:UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numCount
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.view.superview != nil {
            //父view被移除后，会自动调didscrollview
            self.scrollDelgate?.pw_subDidScroll(scrollView: scrollView)
        }
    }
}

extension HomeSubViewController: HomeScrollDelegte {
    var currentScrollView: UIScrollView {
        return tableview
    }
}
