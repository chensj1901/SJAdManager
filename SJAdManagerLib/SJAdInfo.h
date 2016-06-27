//
//  SJAdInfo.h
//  Pods
//
//  Created by 陈少杰 on 16/4/10.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SJAdInfoType) {
    SJAdInfoTypeAdmob=1,
    SJAdInfoTypeBaidu=2,
    SJAdInfoTypeAdwo=3,
    SJAdInfoTypeMax=4
};

@interface SJAdInfo : NSObject

/**
 *	@brief
 */
@property(nonatomic,readonly)SJAdInfoType type;

/**
 *	@brief
 */
@property(nonatomic,readonly)NSString *appKey;

/**
 *	@brief
 */
@property(nonatomic,readonly)NSString *pid;

/**
 *	@brief
 */
@property(nonatomic,readonly)NSInteger zIndex;

/**
 *	@brief
 */
@property(nonatomic,readonly)CGFloat percent;

@property(nonatomic,readonly)NSInteger limit;

@property(nonatomic)NSInteger showCount;

@property(nonatomic,readonly)BOOL hasAdapter;

-(id)initWithRemoteDictionary:(NSDictionary *)dictionary;

-(id)initWithDefault;
@end
