//
//  AFThemeDelegate.h
//  Router
//
//  Created by alete on 2019/5/23.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AFThemeDelegate <NSObject>
/// 单例模式
+(instancetype)vc_shareInstance ;
/// 加载数据模型   json ///文件路径
-(void)vc_loadLocalJson:(NSString *)json ;
/// 主题模式 默认
@property (nonatomic, strong) NSString *vc_style ;


@end
