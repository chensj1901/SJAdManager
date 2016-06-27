//
//  SJMyAdBanner.h
//  Pods
//
//  Created by 陈少杰 on 16/5/9.
//
//

#import <Foundation/Foundation.h>

@interface SJMyAdBanner : NSObject
@property(nonatomic)NSInteger _id;
@property(nonatomic)NSString *imageURL;
@property(nonatomic)NSString *url;

-(id)initWithDictionary:(NSDictionary*)dictionary;
@end
