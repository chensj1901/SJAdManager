//
//  SJAdViewDelegate.h
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import <UIKit/UIKit.h>

@protocol SJAdViewDelegate <NSObject>
-(void)adViewWillLoadBannerView:(UIView *)view;
-(void)adViewDidLoadBannerView:(UIView *)view;
-(void)adViewFailLoadBannerView:(UIView *)view error:(NSError *)error;
-(void)adViewWillShowBannerView:(UIView *)view;
-(void)adViewDidChangeBannerPosition:(UIView *)view;
-(void)adViewDidUpToLimit:(UIView *)view;
@end
