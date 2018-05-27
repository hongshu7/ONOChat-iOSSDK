//
//  ONORouteInfo.h
//  Kiwi
//
//  Created by Kevin Lai on 2018/5/24.
//

#import <Foundation/Foundation.h>

@interface ONORouteInfo : NSObject

@property (nonatomic) NSInteger routeId;
@property (nonatomic, strong) NSString *request;
@property (nonatomic, strong) NSString *response;

@end
