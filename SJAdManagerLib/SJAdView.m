//
//  SJAdBannerView.m
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import "SJAdView.h"
#import "SJAdAdapter.h"
#import "SJAdViewDelegate.h"
#import "SJAdInfoService.h"
#import "SFHFKeychainUtils.h"

@interface SJAdView ()<SJAdAdapterDelegate>
@property(nonatomic)SJAdViewPosition position;
@property(nonatomic)SJAdAdapter *adAdapter;
@property(nonatomic)SJAdViewType type;
@property(nonatomic)SJAdInfo *adInfo;
@end

@implementation SJAdView

-(instancetype)initWithType:(SJAdViewType)type postion:(SJAdViewPosition)position  rootViewController:(UIViewController*)rootViewController{
    if (self=[super initWithFrame:CGRectZero]) {
        self.hidden=YES;
        self.position=position;
        self.type=type;
        
        if (self.type==SJAdViewTypeBanner) {
            [self initAdData];
            Class adapterClass;
            
            if ([SJAdInfoService shareInfoService].infos.count==0) {
                [[SJAdInfoService shareInfoService].infos addObject:[[SJAdInfo alloc]initWithDefault]];
            }
            
            
            for (SJAdInfo *adInfo in [SJAdInfoService shareInfoService].infos) {
                if (adInfo.type<SJAdInfoTypeMax&&(adInfo.showCount<adInfo.limit||adInfo.limit==0)&&adInfo.hasAdapter) {
                    if (adInfo.zIndex>=self.adInfo.zIndex) {
                        self.adInfo=adInfo;
                    }
                }
            }
            if (self.adInfo.type==SJAdInfoTypeAdmob) {
                adapterClass=NSClassFromString(@"AdmobAdapter");
            }
            if (self.adInfo.type==SJAdInfoTypeBaidu) {
                adapterClass=NSClassFromString(@"BaiduAdAdapter");
            }
            if (self.adInfo.type==SJAdInfoTypeAdwo) {
                adapterClass=NSClassFromString(@"AdwoAdAdapter");
            }
            
            if (!self.adInfo) {
                adapterClass=NSClassFromString(@"SJMyAdAdapter");
            }
            
            if (adapterClass) {
                SJAdAdapter *adAdapter=[[adapterClass alloc]init];
                adAdapter.delegate=self;
                adAdapter.rootViewController=rootViewController;
                [adAdapter loadBanner];
                self.adAdapter=adAdapter;
                
            }
        }
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void)initAdData{
    for (SJAdInfo *info in [SJAdInfoService shareInfoService].infos) {
        [self clearAdLimitDataForType:info.type];
        info.showCount = [self showCountForType:info.type];
    }
}

-(NSInteger)showCountForType:(SJAdInfoType)type{
    NSString *mark = [NSString stringWithFormat:@"adShowCount_%d",type];
    NSString *bid=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return [[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:mark error:nil]integerValue];
}

-(void)clearAdLimitDataForType:(SJAdInfoType)type{
    NSString *mark = [NSString stringWithFormat:@"adShowTimeInterval_%d",type];
    NSString *bid=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSTimeInterval lastInterval = [[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:mark error:nil]doubleValue];
    NSTimeInterval nowInterval = [[NSDate date]timeIntervalSince1970];
    if (nowInterval-lastInterval>=3600*24) {
        [SFHFKeychainUtils storeUsername:bid andPassword:[NSString stringWithFormat:@"%f",nowInterval] forServiceName:mark  updateExisting:YES error:nil];
        [self updateShowCountStoreTo:0 type:type];
    }
}

-(void)updateShowCountStoreTo:(NSInteger)showCount type:(SJAdInfoType)type{
    NSString *mark = [NSString stringWithFormat:@"adShowCount_%d",type];
    
    NSString *bid=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [SFHFKeychainUtils storeUsername:bid andPassword:[NSString stringWithFormat:@"%ld",(long)showCount] forServiceName:mark  updateExisting:YES error:nil];
}


-(void)refreshAd{
    if (self.type==SJAdViewTypeBanner) {
        [self.adAdapter refreshBanner];
    }
}


-(void)adAdapterDidReviceAd:(UIView *)view{
    if (self.type==SJAdViewTypeBanner) {
        [self fitSizeToBannerView:view];
    }
    
    self.hidden=NO;
    [self addSubview:view];
    
    if ([self.delegate respondsToSelector:@selector(adViewDidLoadBannerView:)]) {
        [self.delegate adViewDidLoadBannerView:self];
    }
    
    NSLog(@"展示号:%d",self.adInfo.showCount);
    
  
    self.adInfo.showCount++;
    [self updateShowCountStoreTo:self.adInfo.showCount type:self.adInfo.type];
    
    if (self.adInfo&&!!self.adInfo.limit&&self.adInfo.showCount>=self.adInfo.limit) {
        if ([self.delegate respondsToSelector:@selector(adViewDidUpToLimit:)]) {
            [self.delegate adViewDidUpToLimit:self];
        }
    }
}


-(void)adAdapterFailReviceAd:(UIView *)view error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(adViewFailLoadBannerView:error:)]) {
        [self.delegate adViewFailLoadBannerView:view error:error];
    }
}

-(void)adAdapterDidClicked:(UIView *)view{
    self.adInfo.showCount+=10;
    
    [self updateShowCountStoreTo:self.adInfo.showCount type:self.adInfo.type];

    if ([self.delegate respondsToSelector:@selector(adViewWillShowBannerView:)]) {
        [self.delegate adViewWillShowBannerView:self];
    }
}

-(void)fitSizeToBannerView:(UIView *)view{
    CGSize size=view.bounds.size;
    if (self.position==SJAdViewPositionBottom) {
        self.frame = CGRectMake(([self superview].bounds.size.width-size.width)/2, [self superview].bounds.size.height-size.height, size.width, size.height);
    }
    if ([self.delegate respondsToSelector:@selector(adViewDidChangeBannerPosition:)]) {
        [self.delegate adViewDidChangeBannerPosition:self];
    }
}

-(void)didOrientationChange{
    for (UIView *v in self.subviews) {
        if (self.type==SJAdViewTypeBanner) {
            [self fitSizeToBannerView:v];
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
