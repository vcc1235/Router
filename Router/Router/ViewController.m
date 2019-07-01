//
//  ViewController.m
//  Router
//
//  Created by alete on 2019/5/23.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "ViewController.h"
#import "ApiShare.h"
#import <SSZipArchive/SSZipArchive.h>
@interface ViewController () 

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *jsonPath = [NSBundle.mainBundle pathForResource:@"ApiJson" ofType:@"json"];
    NSString *local = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    local = [local stringByAppendingPathComponent:@"api"];
    NSString *json = [local stringByAppendingString:@"/ApiJson.json"];
    [SSZipArchive unzipFileAtPath:jsonPath toDestination:local overwrite:true password:@"94264546" error:nil];
    BOOL islogin = [ApiShare.shareInstance loadApiJson:json];
    if (!islogin) {
        return ;
    }
    NSLog(@"%@",ApiShare.shareInstance.userApi.loginString);
    
    
//    NSString *path = [NSBundle.mainBundle pathForResource:@"sh" ofType:@"zip"];
    
//    NSString *local = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
//    local = [local stringByAppendingPathComponent:@"hello"];
//
//    NSError *error = nil ;
//
//    [SSZipArchive unzipFileAtPath:path toDestination:local overwrite:true password:@"94264546" error:&error];
//    if (error) {
//
//
//    }
}


@end
