//
//  AFThemeManager.h
//  Common
//
//  Created by alete on 2019/3/27.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


/// 颜色属性获取利用继承模式更改
NS_ASSUME_NONNULL_BEGIN

@interface AFThemeManager : NSObject
/// 单例模式
+(instancetype)shareInstance ;
/// 加载数据模型   json ///文件路径
-(void)loadLocalJson:(NSString *)json ;
/// 主题模式 默认
@property (nonatomic, strong) NSString *style ;

@end

NS_ASSUME_NONNULL_END
