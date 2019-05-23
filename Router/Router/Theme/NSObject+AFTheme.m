//
//  NSObject+AFTheme.m
//  Router
//
//  Created by alete on 2019/5/23.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "NSObject+AFTheme.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#define AFThemeString  @"afthemeManager"

@interface NSObject ()

@property (nonatomic, strong) NSDictionary *vc_json ;

@property (nonatomic, strong) NSDictionary *vc_themeDictionary ;

@end

@implementation NSObject (AFTheme)
-(NSDictionary *)vc_json{
    return objc_getAssociatedObject(self, @"vcc_json");
}
-(void)setVc_json:(NSDictionary *)vc_json{
    [self willChangeValueForKey:@"vcc_json"];
    objc_setAssociatedObject(self, @"vcc_json", vc_json, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"vcc_json"];
}

-(NSDictionary *)vc_themeDictionary{
    return objc_getAssociatedObject(self, @"vcc_themeDictionary");
}
-(void)setVc_themeDictionary:(NSDictionary *)vc_themeDictionary{
    [self willChangeValueForKey:@"vcc_themeDictionary"];
    objc_setAssociatedObject(self, @"vcc_themeDictionary", vc_themeDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"vcc_themeDictionary"];
}

+(instancetype)vc_shareInstance{
    static NSObject *__themeInstance = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __themeInstance = [[self alloc]init];
        NSString *value = [NSUserDefaults.standardUserDefaults objectForKey:AFThemeString];
        if (value == nil) {
            __themeInstance.vc_style = @"default" ;
        }else{
            __themeInstance.vc_style = value;
        }
    });
    return __themeInstance ;
}
-(NSString *)vc_style{
    return objc_getAssociatedObject(self, @"vcc_style");
}
/// 更改key
-(void)setVc_style:(NSString *)vc_style{
    [self willChangeValueForKey:@"vcc_style"];
    objc_setAssociatedObject(self, @"vcc_style", vc_style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"vcc_style"];
    [NSUserDefaults.standardUserDefaults setObject:vc_style forKey:AFThemeString];
    NSDictionary *dict = [self.vc_json objectForKey:vc_style];
    self.vc_themeDictionary = dict ;
    [self reloadTheme];
}
/// 加载文件
-(void)vc_loadLocalJson:(NSString *)json{
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:json];
    self.vc_json = dictionary ;
    NSDictionary *dict = [self.vc_json objectForKey:self.vc_style];
    self.vc_themeDictionary = dict ;
    [self reloadTheme];
}
/// 刷新属性值
-(void)reloadTheme{
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(object_getClass(self), &propertyCount);
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);//获取属性名字
        NSString *key = [NSString stringWithUTF8String:name];
        NSString *value = [self.vc_themeDictionary objectForKey:key];
        UIColor *color = [self.class colorWithHexString:value];
        [self setValue:color forKey:key];
    }
}
/// 16进制转颜色值
+(UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    //例子，stringToConvert #ffffff
    if ([cString length] < 4)
        return [UIColor whiteColor];//如果非十六进制，返回白色
    //分别取RGB的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString ;
    if(cString.length>=6)
        bString = [cString substringWithRange:range];
    else
        bString = [cString substringFromIndex:range.location];
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}



@end
