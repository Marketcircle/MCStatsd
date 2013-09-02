MCStatsd [![Build Status](https://travis-ci.org/Marketcircle/MCStatsd.png?branch=master)](https://travis-ci.org/Marketcircle/MCStatsd)
========

MCStatsd is a Objective-C Cocoa client for etsy's [statsd](https://github.com/etsy/statsd) daemon.

MCStatsd is nonblocking and asynchronous.

## Usage

```obj-c
#import <Foundation/Foundation.h>
#import <MCStatsd/MCStatsdClient.h>

MCStatsdClient * client = [MCStatsdClient statsdClientWithAddress:[NSURL URLWithString:@"http://localhost"] namespace:nil];
[client recordCount:@"test_counter" value:5];

```
