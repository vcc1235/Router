//
//  AFColorManager.h
//  Router
//
//  Created by alete on 2019/5/23.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFColorManager : NSObject

/// 单例模式
+(instancetype)shareInstance ;
/// 加载数据模型   json ///文件路径
-(void)loadLocalJson:(NSString *)json ;
/// 主题模式 默认
@property (nonatomic, strong) NSString *style ;

@end

NS_ASSUME_NONNULL_END
