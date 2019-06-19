//
//  AFBundleManager.m
//  Common
//
//  Created by alete on 2019/3/22.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "AFBundleManager.h"
#import <objc/runtime.h>
@interface AFBundleManager ()

@property (nonatomic, strong) NSString *resourceName ;
@property (nonatomic, assign) NSInteger type ;
@property (nonatomic, strong ) NSString *bundleString ;
@property (nonatomic, strong) NSArray <NSString *>*imageNames ;

@end

@interface UIImage (Image)

@end
@implementation UIImage (Image)

+(void)load{
    __weak typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [weakSelf class];
        Method oldMethod = class_getClassMethod(class, @selector(imageNamed:));
        Method newMethod = class_getClassMethod(class, @selector(imageCustomName:));
        method_exchangeImplementations(oldMethod, newMethod);
    });
}

+(UIImage *)imageCustomName:(NSString *)name{
    if (AFBundleManager.shareBundleManager.imageNames && [AFBundleManager.shareBundleManager.imageNames containsObject:name]) {
        return [UIImage imageCustomName:name];
    }
    NSString *img = [NSString stringWithFormat:@"%@/%@",AFBundleManager.shareBundleManager.bundleString,name];
    return [UIImage imageCustomName:img];
}
@end


static const char *_bundlekey = "_bundle_key";
@interface Language : NSBundle
    
@end

@implementation Language
-(NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &_bundlekey);
    return bundle ? [bundle localizedStringForKey:key value:value table:tableName] : [super localizedStringForKey:key value:value table:tableName];
}
    @end


@implementation AFBundleManager
@synthesize bundleString = _bundleString ;
+(instancetype)shareBundleManager{
    static AFBundleManager *__shareInstance = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __shareInstance = [[AFBundleManager alloc]init];
        __shareInstance.type = 0 ;
        object_setClass(NSBundle.mainBundle, [Language class]);
    });
    return __shareInstance ;
}
#pragma mark - image -
-(void)setImageBundle:(NSString *)path{
    NSString *url = [NSBundle.mainBundle pathForResource:path ofType:nil];
    if (url) {
        self.bundleString = path ;
    }else{
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        if (bundle) {
            self.bundleString = bundle.bundlePath ;
        }
    }
}
-(void)setExensistImageNames:(NSArray<NSString *> *)imageNames{
    self.imageNames = imageNames ;
}
#pragma mark - 国际化版本 -
-(void)setBundlePath:(NSString *)path type:(NSInteger)type{
    self.resourceName = path ;
    self.type = type ;
    [self setProjectLanguage];
}
-(void)setLanguage:(NSString *)language{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:@"sys_language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setProjectLanguage];
}
-(void)setProjectLanguage{
    // 然后将设置好的语言存储好，下次进来直接加载
    [[NSUserDefaults standardUserDefaults] setObject:self.currentLanguage forKey:@"sys_language"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (self.type == 1) {
        NSBundle *fbundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:self.resourceName ofType:@"bundle"]];
        objc_setAssociatedObject(NSBundle.mainBundle, &_bundlekey, self.currentLanguage ? [NSBundle bundleWithPath:[fbundle pathForResource:self.currentLanguage ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else if (self.type == 2){
        NSBundle *fbundle = [NSBundle bundleWithPath:self.resourceName];
        objc_setAssociatedObject(NSBundle.mainBundle, &_bundlekey, self.currentLanguage ? [NSBundle bundleWithPath:[fbundle pathForResource:self.currentLanguage ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }else{
        objc_setAssociatedObject(NSBundle.mainBundle, &_bundlekey, self.currentLanguage ? [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:self.currentLanguage ofType:@"lproj"]] : nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
}
-(NSString *)currentLanguage{
    NSString *savedLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"sys_language"];
    return savedLanguage ?: [[NSBundle mainBundle] preferredLocalizations].firstObject;
}
#pragma end
    
@end


