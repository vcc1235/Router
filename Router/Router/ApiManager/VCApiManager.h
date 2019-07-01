//
//  VCApiManager.h
//  Router
//
//  Created by alete on 2019/7/1.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VCApiManager : NSObject

+(instancetype)shareInstance ;

-(BOOL)loadApiJson:(NSString *)jsonPath ;

-(NSString *)host ;


@end




NS_ASSUME_NONNULL_END
