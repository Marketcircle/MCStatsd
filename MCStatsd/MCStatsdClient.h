//
//  MCStatsd.h
//  MCStatsd
//
//  Created by Thomas Bartelmess on 2013-09-01.
//  Copyright (c) 2013 Marketcircle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCStatsdClient : NSObject

+ (MCStatsdClient *)statsdClientWithAddress:(NSURL *)address namespace:(NSString *)namespace;

@property (nonatomic, retain) NSString * namespace;

- (void)recordCount:(NSString *)stat value:(NSUInteger)value;
- (void)recordSample:(NSString *)stat value:(NSUInteger)value interval:(float)interval;
- (void)recordTimeing:(NSString *)stat value:(NSUInteger)time;
- (void)setGauge:(NSString *)stat value:(NSInteger)value;
- (void)adjustGauge:(NSString *)stat value:(NSInteger)value;

@end
