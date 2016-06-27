//
//  SJAdInfoService.m
//  Pods
//
//  Created by 陈少杰 on 16/4/10.
//
//

#import "SJAdInfoService.h"

static SJAdInfoService *_shareInfoService;

@implementation SJAdInfoService
+ (SJAdInfoService *)shareInfoService{
    @synchronized(self) {
        if (!_shareInfoService) {
            _shareInfoService=[[SJAdInfoService alloc]init];
        }
    }
    return _shareInfoService;
}

-(NSMutableArray *)infos{
    if (!_infos) {
        _infos=[NSMutableArray new];
    }
    return _infos;
}

@end
