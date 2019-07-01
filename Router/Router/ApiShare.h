//
//  ApiShare.h
//  Router
//
//  Created by alete on 2019/7/1.
//  Copyright © 2019 aletevcc. All rights reserved.
//

#import "VCApiManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserApi : NSObject

@property (nonatomic, strong) NSString *loginString ;


@end

@interface ApiShare : VCApiManager

@property (nonatomic, strong) UserApi *userApi ;


@end













NS_ASSUME_NONNULL_END
