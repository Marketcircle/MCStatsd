//
//  MCStatsdTests.m
//  MCStatsdTests
//
//  Created by Thomas Bartelmess on 2013-09-01.
//  Copyright (c) 2013 Marketcircle Inc. All rights reserved.
//

#import "MCStatsdClient.h"
#import "MCStatsdClientPrivate.h"
#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>


@interface MCStatsdTests : SenTestCase
@property (nonatomic, strong) MCStatsdClient * client;
@property (nonatomic, strong) OCMockObject * clientMock;
@end


@implementation MCStatsdTests

- (void)setUp {
    [super setUp];
    self.clientMock = [OCMockObject partialMockForObject:[MCStatsdClient statsdClientWithAddress:[NSURL URLWithString:@"http://localhost"] namespace:nil]];
    self.client = (MCStatsdClient *)self.clientMock;
    STAssertNotNil(self.client, @"Error during client init");
}

- (void)tearDown {
    [super tearDown];
    [self.clientMock verify];
    self.client = nil;
}

- (void)testCount {
    [[self.clientMock expect] send:@"stats.test:12|c"];
    [self.client recordCount:@"test" value:12];
}

- (void)testSample {
    [[self.clientMock expect] send:@"stats.test:12|c|@0.10"];
    [self.client recordSample:@"test" value:12 interval:.1];
}

- (void)testTiming {
    [[self.clientMock expect] send:@"stats.test:12|ms"];
    [self.client recordTimeing:@"test" value:12];
}
- (void)testSetGauge {
    [[self.clientMock expect] send:@"stats.test:15|g"];
    [self.client setGauge:@"test" value:15];
}
- (void)testAdjustGaugeAdd {
    [[self.clientMock expect] send:@"stats.test:+15|g"];
    [self.client adjustGauge:@"test" value:15];
}

- (void)testAdjustGaugeSubstract {
    [[self.clientMock expect] send:@"stats.test:-15|g"];
    [self.client adjustGauge:@"test" value:-15];
}

@end
