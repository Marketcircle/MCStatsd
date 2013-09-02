//
//  MCStatsdClientPrivate.h
//  MCStatsd
//
//  Created by Thomas Bartelmess on 2013-09-01.
//  Copyright (c) 2013 Marketcircle Inc. All rights reserved.
//

#import "MCStatsdClient.h"

@interface MCStatsdClient (Private)
- (void)send:(NSString *)command;
@end