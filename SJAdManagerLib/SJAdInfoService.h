//
//  SJAdInfoService.h
//  Pods
//
//  Created by 陈少杰 on 16/4/10.
//
//

#import <Foundation/Foundation.h>
#import "SJAdInfo.h"

@interface SJAdInfoService : NSObject
@property(nonatomic)NSMutableArray *infos;
+ (SJAdInfoService *)shareInfoService;
@end
