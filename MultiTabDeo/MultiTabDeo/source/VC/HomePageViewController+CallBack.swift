//
//  HomePageViewController+CallBack.swift
//  KPLiveShowKit
//
//  Created by 演兽 on 2018/8/14.
//  Copyright © 2018年 ZhuolianSoft. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh
//MARK: - 子VC将要显示回调

extension HomePageViewController {
    //每次page将要显示的时候 调整contentOffset 和 Inset
    //设置回到原点位置
    func adjustSubContentInset(scrollview: UIScrollView, animate: Bool = false) {

        if self.topView.frame.maxY == config.menuHeight {
            //菜单栏已经滑动顶部，不调整偏移值
            if scrollview.contentOffset.y < -config.menuHeight {
                scrollview.setContentOffset(CGPoint(x: 0, y: -config.menuHeight), animated: false)
            }
        }
        else {
            //菜单栏不在顶部的时候，让子vc偏移到菜单栏下面
            if scrollview.contentOffset.y != -self.topView.frame.maxY {
                scrollview.setContentOffset(CGPoint(x: 0, y: -self.topView.frame.maxY), animated: animate)
            }
        }
    }
    
    //子vc结束刷新后
    func sub_endRefresh(scrollview: UIScrollView) {
        adjustSubContentInset(scrollview: scrollview, animate: false)
    }
    
    func getCurrentSubScrollview(index: Int) -> UIScrollView? {
        guard index >= 0 && index < controllers.count else {
            return nil
        }
            
        let vc = controllers[index]
        if vc.isViewLoaded, let d = vc as? HomeScrollDelegte {
            return d.currentScrollView
        }
        return nil
    }
}


//MARK: - TopView 回调

extension HomePageViewController {
    
    //竖直手势滚动回调
    func topViewDidScroll(point: CGPoint, state: UIGestureRecognizerState) {
        
        if state == .began {
            self.collectionView.isUserInteractionEnabled = false
            self.lastOriginY = (self.currentScrollView?.contentOffset ?? CGPoint.zero).y
        }
        else if state == .changed{
            var offSsetY = self.lastOriginY - point.y
            if offSsetY <= -config.containerMaxLength - 120{
                offSsetY = -config.containerMaxLength - 120
            }
            self.currentScrollView?.contentOffset = CGPoint(x: 0, y: offSsetY)
        }
        else {
            self.collectionView.isUserInteractionEnabled = true
            var offSsetY = self.lastOriginY - point.y
            if let contentSize = self.currentScrollView?.contentSize {
                if contentSize.height <  collectionView.frame.height {
                    if offSsetY > contentSize.height - collectionView.frame.height {
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                            self.currentScrollView?.setContentOffset(CGPoint(x: 0, y: -self.config.containerMaxLength), animated: false)
                        }, completion: nil)
                        return
                    }
                }
            }
            
            if offSsetY < -config.containerMaxLength - 80{
                offSsetY = -config.containerMaxLength - 80
                self.currentScrollView?.setContentOffset(CGPoint(x: 0, y: offSsetY), animated: true)
                self.currentScrollView?.mj_header.beginRefreshing()
                return
            }else if offSsetY >= -config.containerMaxLength - 80 && offSsetY <= -config.containerMaxLength {
                self.currentScrollView?.setContentOffset(CGPoint(x: 0, y: -config.containerMaxLength), animated: true)
            }
            else {
                self.currentScrollView?.contentOffset = CGPoint(x: 0, y: offSsetY)

            }
        }
    }
    
    //点击某个menu回调
    func selectMenuIndex(index: Int) {
        self.collectionView.isUserInteractionEnabled = false
        self.selectPageIndex = index
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
        if let s = self.getCurrentSubScrollview(index: index) {
            self.collectionView.isUserInteractionEnabled = true
            self.currentScrollView = s
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.collectionView.isUserInteractionEnabled = true
                self.currentScrollView = self.getCurrentSubScrollview(index: index)
            }
        }
    }
}

//MARK: - 子controller 滚动回调

extension HomePageViewController: SubScrollCallBack {
    
    func pw_subDidScroll(scrollView: UIScrollView) {
        
        if self.collectionView.panGestureRecognizer.state == .changed {
            return   //防止快速左右滑动时，topview跟随下滑
        }
        
        guard let s = currentScrollView, s == scrollView else {
            return
        }
        let offset = scrollView.contentOffset
        
        if offset.y < -config.containerMaxLength {
            //向下拉极限值，刚好超过container高度， 保持不动
            topView.mj_y = config.originOffsetY
        }
        else {
            if offset.y > -(config.containerMinLength) {
                //向上拉到极限值， container显示菜单，保持不动
                topView.mj_y = config.originOffsetY - config.bannerHeight
            }
            else {
                //跟随滑动
                topView.mj_y = -(offset.y + config.containerMaxLength) + config.originOffsetY
            }
        }
    }
}
