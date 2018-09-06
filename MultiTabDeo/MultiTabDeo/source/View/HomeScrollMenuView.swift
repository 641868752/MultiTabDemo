//
//  HomeScrollMenuView.swift
//  ThirdPartDemo
//
//  Created by 演兽 on 2018/8/10.
//  Copyright © 2018年 演兽. All rights reserved.
//

import UIKit

class HomeScrollMenuView: UICollectionView {

    //MARK: - Public
    
    var didSelectMenuItem: ((Int)->Void)?

    //MARK: - Properties
    
    var scrollLine: UIView = {
        let temp = UIView(frame: CGRect.zero)
        temp.backgroundColor = UIColor.red
        temp.layer.cornerRadius = 1
        return temp
    }()
    
    var menus = [PWMenuItem]()
    var space = 25 as CGFloat           //菜单间距
    var itemsOffsetAry = [(CGFloat, CGFloat)]() //(originX, width)
    var selectedIndex = 0
    
    init(frame: CGRect, items: [String], config: PWHomePageConfig) {
        space = config.menuSpace
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.scrollDirection = .horizontal
        
        super.init(frame: frame, collectionViewLayout: flowLayout)

        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(PWHomeMenuLabelCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        self.addSubview(scrollLine)
        self.backgroundColor = UIColor.white
        dataSource = self
        delegate = self
        updateMenus(items: items)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMenus(items: [String]) {
        generateData(items: items)
        adjustMenuToCenter()
    }
    
    //MARK: - public
    
    //滚动条滑动到某一index下
    func updateLineFrame(index: Int, offset: CGFloat, animate: TimeInterval = 0) {
        
        if !isSafeIndex(index: index) {
            return
        }
        
        let menuCenterX = itemsOffsetAry[index].0 + itemsOffsetAry[index].1/2
        var lineOriginX = menuCenterX - self.scrollLine.frame.width/2 + offset
        
        let firstOriginX = itemsOffsetAry[0].0 + itemsOffsetAry[0].1/2 - self.scrollLine.frame.width/2
        let lastOriginX = itemsOffsetAry[itemsOffsetAry.count - 1].0 + itemsOffsetAry[itemsOffsetAry.count - 1].1/2 - self.scrollLine.frame.width/2
        
        if lineOriginX < firstOriginX {
            lineOriginX = firstOriginX
        }
        else if lineOriginX > lastOriginX {
            lineOriginX = lastOriginX
        }
        
        var frame = self.scrollLine.frame
        frame.origin.x = lineOriginX
        UIView.animate(withDuration: animate) {
            self.scrollLine.frame = frame
        }
    }
    
    func setMenuSelected(index: Int, isSelect: Bool) {
        if !isSafeIndex(index: index) {
            return
        }
        
        let item = menus[index]
        item.select = isSelect
        if let cell = cellForItem(at: IndexPath(row: index, section: 0)) as? PWHomeMenuLabelCell{
            cell.fillItem(item: item)
        }
    }
    
    private func generateData(items: [String]) {
        menus.removeAll()
        itemsOffsetAry.removeAll()
        var offsetX = 0 as CGFloat
        items.forEach { (str) in
            //提前计算item长度
            let item = PWMenuItem(str: str)
            menus.append(item)
            //提前计算item的坐标 和 长度
            let p = (offsetX, item.length)
            itemsOffsetAry.append(p)
            offsetX = space + item.length + offsetX
        }
    }
    
    private func adjustMenuToCenter() {
        if menus.count > 0 {
            let maxWidth = menus.reduce(0) { (count, item) -> CGFloat in
                return  count + item.length
                } + CGFloat(menus.count - 1) * space
            
            let itemspace = (self.frame.width - maxWidth)/2
            if itemspace <= 10 {    //超过一屏幕
                contentInset = UIEdgeInsetsMake(0, 10, 0, 10)
            }
            else { //没超过 居中显示
                contentInset = UIEdgeInsetsMake(0, itemspace, 0, itemspace)
            }
            scrollLine.frame = CGRect(x: 0, y: self.frame.height - 6, width: 15, height: 2)
        }
        else { //空数据
            contentInset = UIEdgeInsets.zero
            scrollLine.frame = CGRect.zero
        }
        
        if isSafeIndex(index: selectedIndex) {
            let item = menus[selectedIndex]
            item.select = true
        }
        
        self.reloadData()
    }
    
    func isSafeIndex(index: Int) -> Bool {
        if index >= 0 && index < menus.count{
            return true
        }
        return false
    }
}

//MARK: - 外界滚动 和 点击
extension HomeScrollMenuView {
    // factor 当前的偏移比例
    // 滚动条偏移 = 根据两个index之间中点的距离 * factor
    func pageDidScrolling(originIndex: Int, factor: CGFloat) {
        
        if !isSafeIndex(index: originIndex) {
            return
        }
        
        let originWidth = itemsOffsetAry[originIndex].1
        var farwardIndex = originIndex
        if factor > 0 {  //向前滑动
            if originIndex + 1 < menus.count && isSafeIndex(index: originIndex + 1)  {
                farwardIndex = originIndex + 1
            }
        }
        else {  //向后滚动
            if originIndex - 1 >= 0 && isSafeIndex(index: originIndex - 1) {
                farwardIndex = originIndex - 1
            }
        }
        
        let farawayWidth = itemsOffsetAry[farwardIndex].1
        let centerDistant = (originWidth + farawayWidth)/2 + space
        let lineOffset = centerDistant * factor
        updateLineFrame(index: originIndex, offset: lineOffset)
    }
    
    func pageEndScrollToIndex(_ index: Int) {
        if !isSafeIndex(index: index) {
            return
        }
        
        if selectedIndex == index {
            return
        }

        updateHighListItem(highItem: index)
        selectedIndex = index
        self.updateLineFrame(index: index, offset: 0, animate: 0.2)
        self.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func updateHighListItem(highItem: Int)  {
        let items = menus.filter { (items) -> Bool in
            if items.select == true {
                return true
            }
            return false
        }
        
        items.forEach { (item) in
            item.select = false
        }
        let item = menus[highItem]
        item.select = true
        self.reloadData()
    }
}

extension HomeScrollMenuView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PWHomeMenuLabelCell
        let menu = menus[indexPath.row]
        cell.fillItem(item: menu)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let menu = menus[indexPath.row]
        return CGSize(width: menu.length, height: self.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            return
        }
        
        updateHighListItem(highItem: indexPath.row)
        selectedIndex = indexPath.row
        updateLineFrame(index: indexPath.row, offset: 0, animate: 0.25)
        self.scrollToItem(at: IndexPath(row: indexPath.row, section: 0), at: .centeredHorizontally, animated: true)

        didSelectMenuItem?(indexPath.row)
    }
}

//MARK: - 菜单cell

class PWHomeMenuLabelCell: UICollectionViewCell {
    var menuLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        menuLabel = UILabel(frame: CGRect.zero)
        menuLabel.textAlignment = .center
        menuLabel.font = UIFont.systemFont(ofSize: 15)
        menuLabel.textColor = UIColor.black
        self.contentView.addSubview(menuLabel)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        menuLabel.frame = self.contentView.frame
    }
    
    func fillItem(item: PWMenuItem) {
        menuLabel.text = item.text
        if item.select {
            menuLabel.textColor = UIColor.red
            menuLabel.font = UIFont.boldSystemFont(ofSize: 15)
        }
        else {
            menuLabel.textColor = UIColor.black
            menuLabel.font = UIFont.systemFont(ofSize: 15)
        }
    }
}

//MARK: - 菜单item

class PWMenuItem {
    var text: String
    var length: CGFloat
    var select: Bool = false
    init(str: String) {
        text = str
        //TODO: - 补充
        let tempLength = text.getStringSize(fontSize: 15, size: CGSize(width: 100, height: 16)).width
        length = ceil(tempLength)
    }
}

public extension String{
    //计算文本大小
    public func getStringSize(fontSize: CGFloat, size: CGSize) -> CGSize {
        let font = UIFont.systemFont(ofSize: fontSize)
        let attributes = [NSAttributedStringKey.font:font]
        let option =  NSStringDrawingOptions.usesLineFragmentOrigin
        let rect = self.boundingRect(with: size,options: option,attributes: attributes,context:nil)
        return rect.size
    }
}
