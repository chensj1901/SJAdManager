//
//  SJADManager.h
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import <Foundation/Foundation.h>
#import "SJAdView.h"

extern NSString *const SJAdsBannerChangeNocation;

@interface SJAdManager : NSObject
@property(nonatomic)SJAdView *bannerView;
@property(nonatomic,weak)UIViewController *rootViewController;

+(SJAdManager*)shareController;
+(void)showAdsTail;
+(void)showAdsBanner;
+(void)showAdsBannerAtView:(UIView *)view;
+(void)removeAdsBanner;
+(void)showAdsFullScreen;
+(void)removeAdsFullScreen;
+(void)showPushAds;

@end
