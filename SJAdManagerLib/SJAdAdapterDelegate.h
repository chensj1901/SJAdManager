//
//  SJAdAdapterDelegate.h
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import <UIKit/UIKit.h>

@protocol SJAdAdapterDelegate <NSObject>
-(void)adAdapterDidReviceAd:(UIView *)view;
-(void)adAdapterFailReviceAd:(UIView *)view error:(NSError *)error;
-(void)adAdapterDidClicked:(UIView *)view;
@end
