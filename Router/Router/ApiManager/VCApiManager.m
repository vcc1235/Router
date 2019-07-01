//
//  VCApiManager.m
//  Router
//
//  Created by alete on 2019/7/1.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "VCApiManager.h"
#import <objc/runtime.h>

@interface VCApiManager ()

@property (nonatomic, strong) NSDictionary <NSString *,NSDictionary *>*dictioanry ;

@property (nonatomic, strong) NSMutableDictionary <NSString *,id>*mutableDictionary ;

@end

static VCApiManager *__ApiManager ;
@implementation VCApiManager
-(NSMutableDictionary *)mutableDictionary{
    if (!_mutableDictionary) {
        _mutableDictionary = [[NSMutableDictionary alloc]init];
    }
    return _mutableDictionary ;
}

+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __ApiManager = [[self alloc]init];
    });
    return __ApiManager ;
}

-(void)reloadApi{
    
    NSArray <NSString *> *classArray = self.dictioanry.allKeys ;
    for (NSString *classString in classArray) {
        if (classString == nil || classString.length==0) {
            continue ;
        }
        id objc = [[NSClassFromString(classString) alloc]init];
        if (objc == nil) {
            NSLog(@"%@ class is null",classString);
            continue ;
        }
        [self.mutableDictionary setObject:objc forKey:classString];
        [self setValue:objc forKey:[self lowercastFirstString:classString]];
        NSDictionary *valueDictionary = [self.dictioanry valueForKey:classString];
        NSString *host = [valueDictionary valueForKey:@"host"];
        if (host == nil) {
            host = self.host;
        }
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(object_getClass(objc), &propertyCount);
        for (unsigned int i = 0; i < propertyCount; ++i) {
            objc_property_t property = properties[i];
            const char * name = property_getName(property);//获取属性名字
            NSString *key = [NSString stringWithUTF8String:name];
            NSString *value = [valueDictionary objectForKey:key];
            NSString *url = [host stringByAppendingString:value];
            [objc setValue:url forKey:key];
        }
    }
    
}

-(BOOL)loadApiJson:(NSString *)jsonPath{
    
//    NSError *error ;
//    NSString *json = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        return false ;
//    }
//    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
//    if (error) {
//        return  false ;
//    }
//    if (![dictionary isKindOfClass:[NSDictionary class]]) {
//        return false ;
//    }
    NSDictionary *dictionary = [self readInterfaceValue:jsonPath];
    self.dictioanry = dictionary ;
    [self reloadApi];
    return true ;
}

-(NSString *)lowercastFirstString:(NSString *)string{
    
    if (string == nil) {
        return @"" ;
    }
    if (string.length == 1) {
        return string ;
    }
    NSString *value = [string substringFromIndex:1];
    NSString *key = [string substringWithRange:NSMakeRange(0, 1)];
    return [key.lowercaseString stringByAppendingString:value];
}

-(NSString *)host{
    return @"http://api.vip0.com";
}

///读取模拟接口文档数据
- (NSDictionary *)readInterfaceValue:(NSString *)path {

    //带有注释的json文本
    NSString *allStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSScanner *myScanner = [NSScanner scannerWithString:allStr];//扫描
    NSString *annotStr = nil;
    NSString *jsonStr = allStr;
    while ([myScanner isAtEnd] == NO) {
        //开始扫描
        [myScanner scanUpToString:@"//" intoString:NULL];
        [myScanner scanUpToString:@"\n" intoString:&annotStr];
        //将结果替换
        //注意 这样写jsonStr =  [jsonStr stringByReplacingOccurrencesOfString:annotStr withString:@""]; 无法区分json中的”// 事项“和”// 事项备注“ 两个注释
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n", annotStr] withString:@"\n"];
    }
    if (jsonStr == nil) {return nil;}
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"json解析失败：%@",error);
        return nil;
    }
    return resultDic;
}


@end
