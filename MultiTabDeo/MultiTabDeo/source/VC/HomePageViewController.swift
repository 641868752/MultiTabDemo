//
//  HomePageViewController.swift
//  
//
//  Created by 演兽 on 2018/8/2.
//  Copyright © 2018年 演兽. All rights reserved.
//

import UIKit


protocol SubScrollCallBack: class {
    func pw_subDidScroll(scrollView: UIScrollView)
}

protocol HomeScrollDelegte: class {
    var currentScrollView: UIScrollView { get }
}

public class HomePageViewController: UIViewController {
    
    //MARK: - Properties
    
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = UIScreen.main.bounds.size
        flowLayout.scrollDirection = .horizontal
        let temp = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        temp.collectionViewLayout = flowLayout
        temp.isPagingEnabled = true
        temp.backgroundColor = UIColor.white
        temp.showsVerticalScrollIndicator = false
        temp.showsHorizontalScrollIndicator = false
        if #available(iOS 10.0, *) {
            temp.isPrefetchingEnabled = false
        } else {
        }
        temp.bounces = false
        return temp
    }()
    
    
    //MARK: - data
    var controllers = [UIViewController]()
    var titles = ["第一页","第二页","第三页","第四页","第五页","第三页","第四页","第五页"]
    

    var topView: HomeTopContainerView!
    var currentScrollView: UIScrollView?    //当前subVC的滚动视图
    
    var selectPageIndex = 0
    var lastOriginY = 0 as CGFloat          //当前subVC滚动视图的起点
    var config = PWHomePageConfig()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        edgesForExtendedLayout = []
        configCollectionView()
        configTopView()
        updateData()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        collectionView.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
    }
    
    //MARK: - Config
    
    func configCollectionView() {
        view.addSubview(collectionView)

        collectionView.frame = self.view.frame
        
        collectionView.delegate = self
        collectionView.dataSource = self

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        collectionView.register(
            UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        collectionView.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: .new, context: nil)
    }
    
    func configTopView() {
        topView = HomeTopContainerView(config: config)
        view.addSubview(topView)
        
        topView.didScrollBlock = { [weak self](state,point) in
            self?.topViewDidScroll(point: point, state: state)
        }
        topView.menuView.didSelectMenuItem = { [weak self] (index) in
            self?.selectMenuIndex(index: index)
        }
    }
    

    func updateData() {

        //配置TopView
        self.topView.setMenuItems(items: self.titles)
        
        //配置子controller
        
        self.titles.forEach({ (model) in
            let vc = HomeSubViewController.instantVC()
            vc.scrollDelgate = self
            vc.sub_contentInset = config.containerHeight
            vc.endRefreshBlock = { [weak self](view) in
                if let s = view {
                    self?.sub_endRefresh(scrollview: s)
                }
            }
            self.controllers.append(vc)
        })
    
        self.collectionView.reloadData()
    }
}
