//
//  SJAdAdapter.h
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import <Foundation/Foundation.h>
#import "SJAdAdapterDelegate.h"

@interface SJAdAdapter : NSObject
@property(nonatomic,weak)id<SJAdAdapterDelegate>delegate;
@property(nonatomic,weak)UIViewController *rootViewController;
-(void)loadBanner;
-(void)refreshBanner;
-(void)removeBanner;
@end
