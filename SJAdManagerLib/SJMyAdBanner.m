//
//  SJMyAdBanner.m
//  Pods
//
//  Created by 陈少杰 on 16/5/9.
//
//

#import "SJMyAdBanner.h"

@implementation SJMyAdBanner
-(id)initWithDictionary:(NSDictionary *)dictionary{
    self=[self init];
    if (self) {
        self._id=[[dictionary objectForKey:@"id"]integerValue];
        self.imageURL=[dictionary objectForKey:@"imageURL"];
        self.url=[dictionary objectForKey:@"url"];
    }
    return self;
}
@end
