//
//  SJAdInfo.m
//  Pods
//
//  Created by 陈少杰 on 16/4/10.
//
//

#import "SJAdInfo.h"

@implementation SJAdInfo
-(id)initWithRemoteDictionary:(NSDictionary *)dictionary{
    self=[self init];
    if (self&&[dictionary isKindOfClass:[NSDictionary class]]) {
        _type = [[dictionary objectForKey:@"type"]integerValue];
        _appKey = [dictionary objectForKey:@"appKey"];
        _pid = [dictionary objectForKey:@"pid"];
        _zIndex = [[dictionary objectForKey:@"zIndex"]integerValue];
        _percent = [[dictionary objectForKey:@"percent"]doubleValue];
        _limit = [[dictionary objectForKey:@"limit"]integerValue];
    }
    return self;
}

-(id)initWithDefault{
    self=[self init];
    if (self) {
        _type = SJAdInfoTypeAdmob;
        _appKey = @"";
        _pid = @"ca-app-pub-3825433875529184/1534036351";
        _zIndex = 0;
        _percent = 1.0;
        _limit = 100;
    }
    return self;
}

-(BOOL)hasAdapter{
    switch (self.type) {
        case SJAdInfoTypeAdmob:
            return !!NSClassFromString(@"AdmobAdapter");
            break;
        case SJAdInfoTypeBaidu:
            return  !!NSClassFromString(@"BaiduAdAdapter");
            break;
        default:
            break;
    }
    return NO;
}

@end
