//
//  SJADManager.m
//  Pods
//
//  Created by 陈少杰 on 16/4/9.
//
//

#import "SJADManager.h"
#import "SJSettingRecode.h"
#import "MobClick.h"
#import "SJAdViewDelegate.h"
#import "SJKit.h"
#import "SJAdInfo.h"
#import "SFHFKeychainUtils.h"
#import "SJAdInfoService.h"
#import "SJMyAdBanner.h"

NSString *const SJAdsBannerChangeNocation=@"SJAdsBannerChangeNocation";

@interface SJRecommendApp : NSObject
@property(nonatomic)NSInteger _id;
@property(nonatomic)NSString *appName;
@property(nonatomic)NSString *appIcon;
@property(nonatomic)NSString *appDesc;
@property(nonatomic)NSString *url;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end

@implementation SJRecommendApp
-(id)initWithDictionary:(NSDictionary *)dictionary{
    self=[self init];
    if (self) {
        self._id=[[dictionary objectForKey:@"id"]integerValue];
        self.appName=[dictionary objectForKey:@"appName"];
        self.appIcon=[dictionary objectForKey:@"appIcon"];
        self.appDesc=[dictionary objectForKey:@"appDesc"];
        self.url=[dictionary objectForKey:@"url"];
    }
    return self;
}
@end

static SJAdManager *_adsController;

@interface SJAdManager ()<SJAdViewDelegate>
@property(nonatomic)SJRecommendApp *recommendApp;
@property(nonatomic)BOOL hasShowAdmob;
@end

@implementation SJAdManager
@synthesize bannerView=_bannerView;

+(void)load{
 
}


+(SJAdManager *)shareController{
    if(!_adsController){
        _adsController=[[SJAdManager alloc]init];
    }
    return _adsController;
}

+(void)showAdsTail{
    SJAdManager *ads=[self shareController];
    [ads showAdsTail];
}

+(void)showAdsBanner{
    SJAdManager *ads=[self shareController];
    [ads showAdsBanner];
}

+(void)showAdsBannerAtView:(UIView *)view{
    if([[[SJAdInfoService shareInfoService]infos]count]==0){
        [[self shareController]getAdsKeyWithSuccess:^(NSString *keyStr){
            NSDictionary *dic=[keyStr objectValue];
            if ([dic safeObjectForKey:@"result"]&&[[dic safeObjectForKey:@"result"]isKindOfClass:[NSNumber class]]&&[[dic safeObjectForKey:@"result"]integerValue]==0) {
                for (NSDictionary *adDic in [dic safeObjectForKey:@"ad"]) {
                    SJAdInfo *info=[[SJAdInfo alloc]initWithRemoteDictionary:adDic];
                    [[[SJAdInfoService shareInfoService]infos]addObject:info];
                }
                
            }
            SJAdManager *ads=[self shareController];
            [ads showAdsBannerAtView:view];
        } fail:^(NSError *error) {
            SJAdManager *ads=[self shareController];
            [ads showAdsBannerAtView:view];
        }];
    }else{
        SJAdManager *ads=[self shareController];
        [ads showAdsBannerAtView:view];
    }
    
}

+(void)removeAdsBanner{
    [[self shareController]removeAdsBanner];
}

+(void)showAdsFullScreen{
    SJAdManager *ads=[self shareController];
    [ads showAdsFullScreen];
    
}

+(void)removeAdsFullScreen{
    SJAdManager *ads=[self shareController];
    [ads removeAdsFullScreen];
}

+(void)showPushAds{
    SJAdManager *ads=[self shareController];
    [ads showPushAds];
}

-(instancetype)init{
    if (self=[super init]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeAdType) name:UIApplicationDidBecomeActiveNotification object:nil];
        });
    }
    return self;
}

- (void)statusDidChange:(NSNotification *)notification{
    
    NSDictionary *userInfo = notification.userInfo;
    
    
    NSLog(@"%@",[self titleByStatusCode:[[userInfo objectForKey:@"status"] intValue]]);
    
}

- (NSString *)titleByStatusCode:(int)scode{
    
    NSString *title = @"未知";
    switch (scode) {
        case 0:
            title = @"轮换中";
            break;
        case 1:
            title = @"等展示";
            break;
        case 2:
            title = @"展示中";
            break;
        case 3:
            title = @"等重启";
            break;
        case 4:
            title = @"已过期";
            break;
        case 5:
            title = @"已销毁";
            break;
        default:
            break;
    }
    
    return title;
    
}

-(SJAdView *)bannerView{
    if (!_bannerView) {
        _bannerView=[[SJAdView alloc]initWithType:SJAdViewTypeBanner postion:SJAdViewPositionBottom   rootViewController:self.rootViewController];
        _bannerView.delegate=self;
    }
    return _bannerView;
}
     
-(void)showAdsFullScreen{
    
}

-(void)removeAdsFullScreen{
    
}


-(void)showAdsTail{
    
}

-(void)showAdsBanner{
    UIWindow *mainWindow=[[[UIApplication sharedApplication]windows]objectAtIndex:0];
    [self showAdsBannerAtView:mainWindow];
}

-(void)showAdsBannerAtView:(UIView *)view{
    if (!self.rootViewController) {
        @throw [NSException exceptionWithName:@"No set rootVC" reason:@"请先配置rootVC" userInfo:nil];
    }
    [view addSubview:self.bannerView];
}


-(void)removeAdsBanner{
    [[NSNotificationCenter defaultCenter]postNotificationName:SJAdsBannerChangeNocation object:nil];
    
    [self.bannerView removeFromSuperview];
    self.bannerView=nil;
}

-(void)showPushAds{
    [SJSettingRecode initDB];
    if ([[SJSettingRecode getSet:@"notFirst"]boolValue]) {
        [self getAppRecommendWithSuccess:^{
            SJRecommendApp *app=self.recommendApp;
            NSString *tag=[NSString stringWithFormat:@"ads_count_%ld",(long)self.recommendApp._id];
            NSDateFormatter *format=[[NSDateFormatter alloc]init];
            [format setDateFormat:@"Y-M-d"];
            
            NSString *dateTag=[NSString stringWithFormat:@"ads_showAt_%@",[format stringFromDate:[NSDate date]]];
            if (![[SJSettingRecode getSet:[NSString stringWithFormat:@"ads_%ld",(long)self.recommendApp._id]]boolValue]&&[[SJSettingRecode getSet:tag]integerValue]<2&&[app.url hasPrefix:@"http"]&&[[SJSettingRecode getSet:dateTag]boolValue]==0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MobClick event:@"03_01"];
                    
                    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:app.appName message:app.appDesc delegate:self cancelButtonTitle:nil otherButtonTitles:@"不了",@"去看看🍀", nil];
                    [alertView show];
                    if (arc4random()%3==1) {
                        [SJSettingRecode set:dateTag value:@"1"];
                    }
                });
            }
        } fail:^(NSError *error) {
            
        }];
    }else{
        [SJSettingRecode set:@"notFirst" value:@"1"];
    }
}

-(void)getAppRecommendWithSuccess:(void(^)(void))success fail:(void(^)(NSError* error))fail{
    NSString *bid=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    if ([[NSDate date]timeIntervalSince1970]-[[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"appRecommendInterval" error:nil]doubleValue]>3600*2) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *url=[NSString stringWithFormat:@"%@/op.php?op=getRecommendApp&bid=%@",@"http://zeroisstart.com/gaoxiao",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
            NSError *err1;
            NSData *data=[NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] returningResponse:nil error:&err1];
            NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(),^{
                NSError *err2;
                id dic=[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err2];
                if (err1||err2) {
                    NSError *error=err1?err1:err2;
                    if (fail) {
                        fail(error);
                    }
                }else{
                    @try {
                        if ([dic isKindOfClass:[NSDictionary class]]&&[dic[@"app"]isKindOfClass:[NSDictionary class]]) {
                            SJRecommendApp *app=[[SJRecommendApp alloc]initWithDictionary:dic[@"app"]];
                            self.recommendApp=app;
                            
                            if (success) {
                                [SFHFKeychainUtils storeUsername:bid andPassword:[NSString stringWithFormat:@"%f",[[NSDate date]timeIntervalSince1970]] forServiceName:@"appRecommendInterval" updateExisting:YES error:nil];
                                success();
                            }
                        }else{
                            NSError *error=[NSError errorWithDomain:@"404" code:404 userInfo:nil];
                            if (fail) {
                                fail(error);
                            }
                        }
                    }
                    @catch (NSException *exception) {
                        NSError *error=[NSError errorWithDomain:@"404" code:404 userInfo:nil];
                        if (fail) {
                            fail(error);
                        }
                        
                    }
                    @finally {
                        
                    }
                }
            });
        });
    }else{
        NSError *error=[NSError errorWithDomain:@"too more" code:404 userInfo:nil];
        if (fail) {
            fail(error);
        }
    }
}

-(void)getAdsKeyWithSuccess:(void(^)(NSString *keyStr))success fail:(void(^)(NSError* error))fail{
    NSString *bid=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    NSString *url=[NSString stringWithFormat:@"%@/fanyi.php?%@",@"http://zeroisstart.com",[[@{@"op":@"ad",@"bid":bid} dictionaryWithSign]dictionaryToURLStr]];
    if ([[NSDate date]timeIntervalSince1970]-[[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyTimeInterval" error:nil]doubleValue]>3600*2) {
        [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] queue:[NSOperationQueue new] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            NSString *plistKeys=[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"ad" ofType:@"bin"] encoding:NSUTF8StringEncoding error:nil];
            NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            if (str&&str.length>0&&!connectionError&&[[[str objectValue]safeObjectForKey:@"ad"]count]>0) {
                [SFHFKeychainUtils storeUsername:bid andPassword:str forServiceName:@"adsKeyJSON" updateExisting:YES error:nil];
                [SFHFKeychainUtils storeUsername:bid andPassword:[NSString stringWithFormat:@"%f",[[NSDate date]timeIntervalSince1970]] forServiceName:@"adsKeyTimeInterval" updateExisting:YES error:nil];
            }else if([SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyJSON" error:nil].length==0&&plistKeys.length>0){
                [SFHFKeychainUtils storeUsername:bid andPassword:plistKeys forServiceName:@"adsKeyJSON" updateExisting:YES error:nil];
                [SFHFKeychainUtils storeUsername:bid andPassword:[NSString stringWithFormat:@"%f",[[NSDate date]timeIntervalSince1970]] forServiceName:@"adsKeyTimeInterval" updateExisting:YES error:nil];
            }
            
            NSError *keyError;
            NSString *keyStr=[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyJSON" error:&keyError];
            if (keyStr&&keyStr.length>0) {
                    dispatch_async(dispatch_get_main_queue(),^{
                        success(keyStr);
                    });
               
            }else{
                dispatch_async(dispatch_get_main_queue(),^{
                    fail(connectionError?connectionError:keyError);
                });
            }
            
        }];
    }else if ([SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyJSON" error:nil]&&[SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyJSON" error:nil].length>0){
        dispatch_async(dispatch_get_main_queue(),^{
            success([SFHFKeychainUtils getPasswordForUsername:bid andServiceName:@"adsKeyJSON" error:nil]);
        });
    }else{
        dispatch_async(dispatch_get_main_queue(),^{
            fail(nil);
        });
    }
    
}

-(void)changeAdType{
    [self removeAdsBanner];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showAdsBanner];
    });
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        [MobClick event:@"03_03"];
        NSString *tag=[NSString stringWithFormat:@"ads_count_%ld",(long)self.recommendApp._id];
        [SJSettingRecode set:tag value:[NSString stringWithFormat:@"%ld",(long)([[SJSettingRecode getSet:tag]integerValue]+1)]];
    }
    if (buttonIndex==1) {
        [MobClick event:@"03_02"];
        
        [SJSettingRecode set:[NSString stringWithFormat:@"ads_%ld",(long)self.recommendApp._id] value:@"1"];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.recommendApp.url]];
    }
}

#pragma mark -
-(void)adViewDidLoadBannerView:(UIView *)view{
    
    NSLog(@"banner显示成功");
}

-(void)adViewDidUpToLimit:(UIView *)view{
    [self performSelector:@selector(changeAdType) withObject:nil afterDelay:29];
}

-(void)adViewWillShowBannerView:(UIView *)view{
}

-(void)adViewFailLoadBannerView:(UIView *)view error:(NSError *)error{
    NSLog(@"banner显示失败，%@",error);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.bannerView refreshAd];
    });
}


-(void)adViewDidChangeBannerPosition:(UIView *)view{
    [[NSNotificationCenter defaultCenter]postNotificationName:SJAdsBannerChangeNocation object:view];
}

-(BOOL)shouldAlertQAView:(UIAlertView *)alertView{
    return NO;
}

- (void)webBrowserShare:(NSString *)url{
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
