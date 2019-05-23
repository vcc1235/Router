//
//  Router.h
//  Common
//
//  Created by alete on 2019/3/21.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 跳转模式
typedef NS_OPTIONS(NSInteger, RTTransition){
    /// present 跳转
    RTTransitionPresent,
    /// push 跳转
    RTTransitionPush,
    /// present 跳转 (带导航栏)
    RTTRansitionNAVPresent,
    /// 无需跳转 用作创建控制器
    RTTransitionNone
    
};
typedef void(^RTCompletion)(NSError * __nullable error, id __nullable obj);
@protocol RouterParamDelegate <NSObject>
/// 参数
@property (nonatomic, strong) NSDictionary *routerParams ;
/// 跳转完成后回调操作
@property (nonatomic, strong) RTCompletion routerCompletion ;
@optional
/// 需要参数的属性列表  利用 KVC 模式传参
-(NSArray<NSString *>*)routerTopropertys ;

@end

@protocol RouterHandelDelegate <NSObject>
@required
-(NSString *)host ;

-(BOOL)isLogin ;

@optional
-(void)transitionWithTargetName:(NSString *)viewControllerName Params:(NSDictionary *__nullable)params ;

@end

/// 设置类别 代理模式
@interface UIViewController (RouterDelegate) <RouterParamDelegate>

@end

/// 数据操作
@interface RouterModel : NSObject

@property (nonatomic, strong) id first ;
@property (nonatomic, strong) id second ;
@property (nonatomic, strong) id third ;
@property (nonatomic, strong) id fouth ;
@property (nonatomic, strong) id fifth ;
@property (nonatomic, strong) id sex ;

@end

@interface Router : NSObject
/// 跳转 导航类
+(void)navigationController:(Class)className ;
/// 项目名设置  主要针对 swift 控制器的跳转
+(BOOL)swiftClassWithProjectName:(NSString *)projectName;
/// 处理外部跳转
+(BOOL)routerHandleOpenURL:(NSURL *)url withDelegate:(id<RouterHandelDelegate>)delegate ;
/**
 进行跳转调整
 @param target 操作控制器
 @param viewControllerName 目标控制器名
 @param params 传入参数
 @param transition 跳转模式
 @return 目标控制器
 */
+(UIViewController *)transitionWithSource:(UIViewController *__nullable)target Target:(NSString *__nonnull)viewControllerName Params:(NSDictionary *__nullable)params TransitionMode:(RTTransition)transition ;
/**
 进行跳转调整
 @param target 操作控制器
 @param viewControllerName 目标控制器名
 @param params 传入参数
 @param transition 跳转模式
 @param complete 操作完成
 @return 目标控制器
 */
+(UIViewController *)transitionWithSource:(UIViewController *__nullable)target Target:(NSString *__nonnull)viewControllerName Params:(NSDictionary *__nullable)params TransitionMode:(RTTransition)transition complete:(RTCompletion __nullable)complete ;

/**
 方法的执行

 @param targetName 执行者名
 @param selectorName 执行方法名
 @param params 参数传递
 @return 返回值
 */
+(id)performTarget:(NSString *)targetName selectorName:(NSString *)selectorName Params:(void(^)(RouterModel *make))params ;

/**
 方法执行
 @param target target description
 @param selectorName selectorName description
 @param params params description
 @return return value description
 */
+(id)performObject:(NSObject *)target selectorName:(NSString *)selectorName Params:(void (^)(RouterModel * _Nonnull))params ;

@end

NS_ASSUME_NONNULL_END
