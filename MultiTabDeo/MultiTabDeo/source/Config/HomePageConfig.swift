//
//  PWHomePageConfig.swift
//  ThirdPartDemo
//
//  Created by 演兽 on 2018/8/10.
//  Copyright © 2018年 演兽. All rights reserved.
//

import UIKit

struct PWHomePageConfig {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height


    //MARK: - constant
    
    var bannerHeight = 107 as CGFloat        //运营位高度
    var menuHeight = 44 as CGFloat          //菜单高度
    var menuSpace = 25 as CGFloat           //菜单间距
    var originOffsetY = 0 as CGFloat      //起始偏移值
    
    //MARK: - banner + menu 高度
    
    var containerMaxLength: CGFloat {
        return bannerHeight + menuHeight + originOffsetY
    }
    
    var containerMinLength: CGFloat {
        return originOffsetY + menuHeight
    }
    
    var containerHeight: CGFloat {
        return bannerHeight + menuHeight
    }
}
