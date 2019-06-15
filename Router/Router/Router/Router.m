//
//  Router.m
//  Common
//
//  Created by alete on 2019/3/21.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "Router.h"
#import <objc/runtime.h>

@implementation UIViewController (RouterDelegate)
-(NSDictionary *)routerParams{
   return objc_getAssociatedObject(self, @"routerparams");
}
-(void)setRouterParams:(NSDictionary *)routerParams{
    [self willChangeValueForKey:@"routerparams"];
    objc_setAssociatedObject(self, @"routerparams", routerParams, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"routerparams"];
}

-(void)setRouterCompletion:(RTCompletion)routerCompletion{
    [self willChangeValueForKey:@"routerCompletion"];
    objc_setAssociatedObject(self, @"routerCompletion", routerCompletion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"routerCompletion"];
}
-(RTCompletion)routerCompletion{
    return objc_getAssociatedObject(self, @"routerCompletion");
}
@end

@implementation RouterModel


@end

static NSString *__projectName = @"IM" ;
static Class __className ;
@implementation Router
+(void)navigationController:(Class)className{
    __className = className ;
}
+(BOOL)swiftClassWithProjectName:(NSString *)projectName{
    __projectName = projectName ;
    return true ;
}

/// 
+(BOOL)routerHandleOpenURL:(NSURL *)url withDelegate:(id<RouterHandelDelegate>)delegate{
    NSString *viewControllerName ;
    if (![delegate isLogin]) {
        return false ;
    }
    NSMutableDictionary *param = [[NSMutableDictionary alloc]init];
    if (![url.host isEqualToString:delegate.host]) {
        viewControllerName = @"web" ;
        NSString *http = [NSString stringWithFormat:@"http://%@%@?%@",url.host,url.path,url.query];
        [param setObject:http forKey:@"url"];
        [delegate transitionWithTargetName:viewControllerName Params:param];
        return true ;
    }
    NSString *path = url.path ;
    if (path && path.length>0) {
        path = [url.path substringFromIndex:1] ;
        NSArray *paths = [path componentsSeparatedByString:@"/"];
        viewControllerName = paths.firstObject ;
    }else{
        path = url.host ;
    }
    NSString *query = url.query;
    if (query && query.length>0) {
        NSArray <NSString *>*querys = [query componentsSeparatedByString:@"&"];
        [querys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:@"="]) {
                NSRange range = [obj rangeOfString:@"="];
                NSString *key = [obj substringToIndex:range.location];
                NSString *value = [obj substringFromIndex:range.location+1];
                [param setObject:value forKey:key];
            }
        }];
    }
    [delegate transitionWithTargetName:viewControllerName Params:param];
    return true ;
}

+(UIViewController *)transitionWithSource:(UIViewController *)target Target:(NSString *)viewControllerName Params:(NSDictionary *)params TransitionMode:(RTTransition)transition{
    return [self transitionWithSource:target Target:viewControllerName Params:params TransitionMode:transition complete:nil];
}
/**
 本地组件(控制器)切换
 @param target 调用者
 @param viewControllerName targetName
 @param params params
 @param transition transition
 @return UIViewController object
 */
+(UIViewController *)transitionWithSource:(UIViewController *)target Target:(NSString *)viewControllerName Params:(NSDictionary *)params TransitionMode:(RTTransition)transition complete:(RTCompletion)complete{
    
    UIViewController *viewController;
    if (NSClassFromString(viewControllerName)) {
        viewController = [[NSClassFromString(viewControllerName) class] new];
    }else if(NSClassFromString([NSString stringWithFormat:@"%@.%@",__projectName,viewControllerName])){
        viewController = [[NSClassFromString([NSString stringWithFormat:@"%@.%@",__projectName,viewControllerName]) class]new];
    }
    
    if (viewController == nil) {
        // 处理无响应请求的地方之一。
        // 可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求
        return nil;
    }
    
    if (![viewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    
    if ([target isKindOfClass:[UIViewController class]]) {
        target = (UIViewController *)target;
    }
    else {
        target = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if ([viewController respondsToSelector:@selector(routerTopropertys)]) {
        NSArray<NSString *>*list = [viewController routerTopropertys];
        for (NSString *key in list) {
            id object = [params objectForKey:key];
            if (object != nil) {
                 /// KVC
                [viewController setValue:object forKey:key];
            }
        }
    }
    viewController.routerParams = params ;
    viewController.routerCompletion = complete ;
    switch (transition) {
        case RTTransitionPush:
        {
            if (!target.navigationController) {
                return viewController;
            }
            if ([target.navigationController.viewControllers count]==1) {
                viewController.hidesBottomBarWhenPushed = YES;
            }
            [target.navigationController pushViewController:viewController animated:true];
            
        }break;
        case RTTransitionPresent:
        {
            [target presentViewController:viewController animated:true completion:nil];
            
        }break;
        case RTTRansitionNAVPresent:
        {
            UINavigationController *navigationController ;
            if (__className) {
                navigationController = [[__className alloc]initWithRootViewController:viewController];
            }else{
                navigationController = [[UINavigationController alloc]initWithRootViewController:viewController];
            }
            [target presentViewController:navigationController animated:YES completion:nil];
        }break ;
        case RTTransitionNone:
        {
            return viewController;
            break;
        }
    }
    
    return viewController;
}




+(id)performObject:(NSObject *)target selectorName:(NSString *)selectorName Params:(void (^)(RouterModel * _Nonnull))params{
    
    if (target == nil) {
        // 处理无响应请求的地方之一。
        // 可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求,也可以跳转App内url。
        return nil;
    }
    
    SEL action = NSSelectorFromString(selectorName);
    if (action == nil) {
        // 处理无响应请求的地方之一。
        // 可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求
        return nil;
    }
    RouterModel *model = [[RouterModel alloc]init];
    if (params) {
        params(model);
    }
    // 可以响应
    if ([target.class respondsToSelector:action] ||
        [target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    
    // 有可能target是Swift对象
    NSString *actionString = [NSString stringWithFormat:@"%@WithParams:", selectorName];
    action = NSSelectorFromString(actionString);
    
    // 可以响应
    if ([target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    
    // 处理无响应请求的地方之二
    // 如果无响应，则尝试调用对应target的notFound方法统一处理
    action = NSSelectorFromString(@"notFound:");
    if ([target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    else {
        // 处理无响应请求的地方之三，
        // 在notFound都没有的时候，可以用之前的固定的target顶上
        return nil;
    }
    
    
}

/**
 本地组件调用
 
 @param targetName targetName
 @param selectorName actionName
 @param params params
 @return return value of method maped action
 */
+(id)performTarget:(NSString *)targetName selectorName:(NSString *)selectorName Params:(void(^)(RouterModel *make))params{
    
    NSObject *target;
    if (NSClassFromString(targetName)) {
        target = [[NSClassFromString(targetName) class] new];
    }else{
        return nil ;
    }
    if (target == nil) {
        // 处理无响应请求的地方之一。
        // 可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求,也可以跳转App内url。
        return nil;
    }
    
    SEL action = NSSelectorFromString(selectorName);
    if (action == nil) {
        // 处理无响应请求的地方之一。
        // 可以事先给一个固定的target专门用于在这个时候顶上，然后处理这种请求
        return nil;
    }
    RouterModel *model = [[RouterModel alloc]init];
    if (params) {
        params(model);
    }
    // 可以响应
    if ([target.class respondsToSelector:action] ||
        [target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    
    // 有可能target是Swift对象
    NSString *actionString = [NSString stringWithFormat:@"%@WithParams:", selectorName];
    action = NSSelectorFromString(actionString);
    
    // 可以响应
    if ([target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    
    // 处理无响应请求的地方之二
    // 如果无响应，则尝试调用对应target的notFound方法统一处理
    action = NSSelectorFromString(@"notFound:");
    if ([target respondsToSelector:action]) {
        return [self performTarget:target Action:action Params:model];
    }
    else {
        // 处理无响应请求的地方之三，
        // 在notFound都没有的时候，可以用之前的固定的target顶上
        return nil;
    }
    

}

/**
 私有方法，perform
 
 @param target target
 @param action action
 @param model params
 @return return value of method peformed
 */
+(id)performTarget:(NSObject *)target Action:(SEL)action  Params:(RouterModel *)model {
    
    NSMethodSignature* methodSig;
    // 优先调用类方法
    if ([target.class respondsToSelector:action]) {
        methodSig = [target.class methodSignatureForSelector:action];
    }
    else {
        methodSig = [target methodSignatureForSelector:action];
    }
    if(methodSig == nil) {
        return nil;
    }
    
    // 获取invocation
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    
    // 入参
    for (NSInteger idx = 2; idx < methodSig.numberOfArguments; idx ++ ) {
        id obj = nil;
        switch (idx) {
            case 2:
                obj = model.first ;
                break;
            case 3:
                obj = model.second ;
                break;
            case 4:
                obj = model.third ;
                break;
            case 5:
                obj = model.fouth ;
                break;
            case 6:
                obj = model.fifth ;
                break;
            case 7:
                obj = model.sex ;
                break;
            default:
                break;
        }
        // 类型判断，参数值校验传入
        if ([obj isKindOfClass:[NSNumber class]]) {
            
            // 由于传入的基础类型float cgfloat无法判断，所以用方法参数类型
            const char *type = [methodSig getArgumentTypeAtIndex:idx];
            
            NSNumber *number = (NSNumber *)obj;
            if (strcmp(type, @encode(CGFloat)) == 0) {
                CGFloat num = number.floatValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(NSInteger)) == 0) {
                NSInteger num = number.integerValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(NSUInteger)) == 0) {
                NSUInteger num = number.unsignedIntegerValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(float)) == 0) {
                CGFloat num = number.floatValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(double)) == 0) {
                double num = number.doubleValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(int)) == 0) {
                int num = number.intValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else if (strcmp(type, @encode(BOOL)) == 0) {
                BOOL num = number.boolValue;
                [invocation setArgument:&num atIndex:idx];
            }
            else { // 就是NSNumber类型
                [invocation setArgument:&number atIndex:idx];
            }
        }
        else if ([obj isKindOfClass:[NSValue class]]) {
            
            NSValue *value = (NSValue *)obj;
            if (strcmp(value.objCType, @encode(CGSize)) == 0) {
                CGSize size = value.CGSizeValue;
                [invocation setArgument:&size atIndex:idx];
            }
            else if (strcmp(value.objCType, @encode(CGRect)) == 0) {
                CGRect rect = value.CGRectValue;
                [invocation setArgument:&rect atIndex:idx];
            }
            else if (strcmp(value.objCType, @encode(NSRange)) == 0) {
                NSRange range = value.rangeValue;
                [invocation setArgument:&range atIndex:idx];
            }
            else if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
                CGPoint point = value.CGPointValue;
                [invocation setArgument:&point atIndex:idx];
            }
        }
        else {
            [invocation setArgument:&obj atIndex:idx];
        }
    }
    
    [invocation setSelector:action];
    if ([target.class respondsToSelector:action]) {
        [invocation setTarget:target.class];
    }
    else {
        [invocation setTarget:target];
    }
    [invocation invoke];
    
    // 处理返回值
    const char* retType = [methodSig methodReturnType];
    
    if (strcmp(retType, @encode(void)) == 0) {
        return nil;
    }
    else if (strcmp(retType, @encode(NSInteger)) == 0) {
        NSInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    else if (strcmp(retType, @encode(BOOL)) == 0) {
        BOOL result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    else if (strcmp(retType, @encode(CGFloat)) == 0) {
        CGFloat result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    else if (strcmp(retType, @encode(NSUInteger)) == 0) {
        NSUInteger result = 0;
        [invocation getReturnValue:&result];
        return @(result);
    }
    
    void *result = nil;
    [invocation getReturnValue:&result];
    return (__bridge id)result;
    
}









@end
