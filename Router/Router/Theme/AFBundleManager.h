//
//  AFBundleManager.h
//  Common
//
//  Created by alete on 2019/3/22.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

#define Localize(key)  NSLocalizedString(key, nil)
@interface AFBundleManager : NSObject
/// 单例模式
+(instancetype)shareBundleManager ;
#pragma mark - 国际化版本 -
/**
 type 1 path 为bundle 名
 type 2 path 为 bundle 路径
 */
-(void)setBundlePath:(NSString *)path type:(NSInteger)type ;
/// 设置语言
-(void)setLanguage:(NSString *)language ;
/// 当前语言
-(NSString *)currentLanguage ;
#pragma end

#pragma mark - 图片 -
@property (nonatomic, strong , readonly) NSString *bundleString ;
/// 设置图片路径
-(void)setImageBundle:(NSString *)path ;
#pragma end

@end

NS_ASSUME_NONNULL_END
