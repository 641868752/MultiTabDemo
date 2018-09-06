//
//
//  ThirdPartDemo
//
//  Created by 演兽 on 2018/8/9.
//  Copyright © 2018年 演兽. All rights reserved.
//

import UIKit

class HomeTopContainerView: UIView, UIGestureRecognizerDelegate {

    var bannerView: UIView!
    var menuView: HomeScrollMenuView!
    
    var panGesutre: UIPanGestureRecognizer!
    var didScrollBlock: ((UIGestureRecognizerState, CGPoint) -> Void)?
    
    
    var config: PWHomePageConfig!
    
    init(config: PWHomePageConfig) {
        self.config = config
        super.init(frame: CGRect(x: 0, y: config.originOffsetY, width: PWHomePageConfig.screenWidth, height: config.containerHeight))
        self.configSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configSubView() {
        
        bannerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: config.bannerHeight))
        bannerView.backgroundColor = UIColor.orange
        
        self.addSubview(bannerView)

        menuView = HomeScrollMenuView(frame: CGRect(x: 0, y: config.bannerHeight, width: self.frame.width, height: config.menuHeight), items: [], config: config)
        self.addSubview(menuView)

        panGesutre = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(ges:)))
        panGesutre.delegate = self
        self.addGestureRecognizer(panGesutre)
    }
    
    @objc func panGestureAction(ges: UIPanGestureRecognizer) {
        let point = ges.translation(in: self)
        didScrollBlock?(ges.state,point)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == self.panGesutre {
            
            let point = self.panGesutre.translation(in: self)
            if abs(point.y) > abs(point.x) {
                return true
            }
            return false
        }
        return true
    }
    
    func setMenuItems(items: [String]) {
        menuView.updateMenus(items: items)
        menuView.updateLineFrame(index: 0, offset: 0)
    }
    
}

extension HomeTopContainerView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = indexPath.row == 0 ? UIColor.red : UIColor.black
        return  cell
    }
    
}
