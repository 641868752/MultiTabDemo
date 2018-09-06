//
//  HomePageViewController+delegate.swift
//  KPLiveShowKit
//
//  Created by 演兽 on 2018/8/14.
//  Copyright © 2018年 ZhuolianSoft. All rights reserved.
//

import Foundation
import UIKit
//MARK: - UICollectionVIew delegate & datasource

extension HomePageViewController: UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate, UICollectionViewDelegateFlowLayout {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
            if let vc = findViewController(view: subview) {
                vc.willMove(toParentViewController: nil)
                vc.removeFromParentViewController()
                vc.didMove(toParentViewController: nil)
            }
        }
        
        let vc = controllers[indexPath.row]
        vc.view.frame = self.collectionView.frame
        
        cell.contentView.addSubview(vc.view)
        vc.willMove(toParentViewController: self)
        self.addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        
        if let s = getCurrentSubScrollview(index: indexPath.row) {
            adjustSubContentInset(scrollview: s)
            if currentScrollView == nil {
                currentScrollView = s
            }
        }
        
        return  cell
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //滚动停止 调整菜单和滚动条
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / self.collectionView.frame.width)
        selectPageIndex = index

        if let s = getCurrentSubScrollview(index: index) {
            currentScrollView = s
        }
        topView.menuView.pageEndScrollToIndex(index)
        removeOtherSubVC(index: selectPageIndex)
    }
    
    private func removeOtherSubVC(index: Int) {
        if controllers.count <= 0 {
            return
        }
        for i in 0...(controllers.count - 1) {
            if i != index {
                let vc = self.controllers[i]
                if vc.isViewLoaded {
                    vc.view.removeFromSuperview()
                    vc.willMove(toParentViewController: nil)
                    vc.removeFromParentViewController()
                    vc.didMove(toParentViewController: nil)
                }
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.x
        let originOffset = CGFloat(selectPageIndex) * scrollView.frame.width
        let diffWidth = currentOffset - originOffset
        let factor = diffWidth / self.collectionView.frame.width
        self.topView.menuView.pageDidScrolling(originIndex: self.selectPageIndex, factor: factor)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "state" {
            guard let _ = change?[NSKeyValueChangeKey.newKey]  else {
                return
            }
            
            let state = collectionView.panGestureRecognizer.state
            if state == .began {
                topView.panGesutre.isEnabled = false
            }
            else if state == .ended ||
                state == .cancelled ||
                state == .failed {
                topView.panGesutre.isEnabled = true
            }
        }
    }
    
    private func findViewController(view: UIView) -> UIViewController? {
        if let nextResponder = view.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = view.next as? UIView {
            return findViewController(view: nextResponder)
        } else {
            return nil
        }
    }
}
