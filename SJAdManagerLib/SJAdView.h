//
//  SJAdBannerView.h
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import <UIKit/UIKit.h>
#import "SJAdViewDelegate.h"

typedef NS_ENUM(NSInteger,SJAdViewType){
    SJAdViewTypeBanner
};

typedef NS_ENUM(NSInteger,SJAdViewPosition){
    SJAdViewPositionBottom
};

@interface SJAdView : UIView
@property(weak,nonatomic)id<SJAdViewDelegate> delegate;
@property(nonatomic)BOOL isMy;

-(instancetype)initWithType:(SJAdViewType)type postion:(SJAdViewPosition)position  rootViewController:(UIViewController*)rootViewController;
-(void)refreshAd;
@end
