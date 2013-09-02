//
//  MCStatsd.h
//  MCStatsd
//
//  Created by Thomas Bartelmess on 2013-09-01.
//  Copyright (c) 2013 Marketcircle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCStatsdClient : NSObject
/**
 * Creates a new MCStatsdClient with a given address and namespace
 *
 * @param address Address (host and port) of the statsd server
 * @param namespace namespace for statistics. "stats" is used when this parameter is nil
 *
 * @return A initalized MCStatsdClient, or nil when an error occured
 */
+ (MCStatsdClient *)statsdClientWithAddress:(NSURL *)address namespace:(NSString *)namespace;

@property (nonatomic, retain) NSString * namespace;

/**
 * Adjusts the specified counter by a given delta.
 *
 * @param name the name of the counter to adjust
 * @param value the amount to adjust the counter by
 *
 * @see recordSample:value:interval:
 */

- (void)recordCount:(NSString *)stat value:(NSUInteger)value;

/**
 * Adjusts the specified counter by a given delta by providing a sampling interval.
 *
 * @param name the name of the counter to adjust
 * @param value the amount to adjust the counter by
 * @param interval the interval in ms the probile is sampled in
 *
 * @see recordSample:value:
 */

- (void)recordSample:(NSString *)stat value:(NSUInteger)value interval:(float)interval;

/**
 * Records an execution time in milliseconds for the specified named operation.
 *
 * @param name the name of the timed operation
 * @param time in milliseconds
 */

- (void)recordTimeing:(NSString *)stat value:(NSUInteger)time;

/**
 *  Records the latest fixed value for the specified named gauge.
 *
 * @param name the name of the gauge
 * @param value fixed value for the gauge
 *
 * @see adjustGauge:value:
 */
- (void)setGauge:(NSString *)stat value:(NSInteger)value;

/**
 *  Adjustes a named gauge by a delta
 *
 * @param name the name of the gauge
 * @param value to add or substract from the gauge value
 *
 * @see setGauge:value:
 */
- (void)adjustGauge:(NSString *)stat value:(NSInteger)value;

@end
