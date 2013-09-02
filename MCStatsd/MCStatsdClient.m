//
//  MCStatsd.m
//  MCStatsd
//
//  Created by Thomas Bartelmess on 2013-09-01.
//  Copyright (c) 2013 Marketcircle Inc. All rights reserved.
//

#import "MCStatsdClient.h"

#include <netinet/in.h>

#import "MCStatsdClientPrivate.h"

#define DEFAULT_PORT 8125



static dispatch_queue_t statsd_queue;

void init_statsd_queue() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        statsd_queue = dispatch_queue_create("com.marketcircle.statsd", 0);
    });
}


@interface MCStatsdClient() {
    CFSocketRef socket;
}
@end


@implementation MCStatsdClient
@synthesize namespace;


+ (MCStatsdClient *)statsdClientWithAddress:(NSURL *)address namespace:(NSString *)namespace {
    MCStatsdClient * client = [[MCStatsdClient alloc] initWithAddress:address];
    if (!namespace) {
        client.namespace = @"stats";
    } else {
        client.namespace = namespace;
    }
    return client;
}
- (id)initWithAddress:(NSURL *)address {
    self = [super init];
    if (self) {
        init_statsd_queue();
        // get the host name string
        if (!address.host) {
            NSLog(@"nil address given");
            return nil;
        }
        
        // get the port number
        int port = address.port.intValue;
        if (!port)
            port = DEFAULT_PORT;
        
        // need to cast the host to a CFStringRef for the next part
        CFStringRef hostname = (CFStringRef)(address.host);
        
        // try to resolve the hostname
        CFHostRef host = CFHostCreateWithName(kCFAllocatorDefault, hostname);
        
        
        if (!host) {
            NSLog(@"Could not allocate CFHost to lookup IP address of statsd");
            return nil;
        }
        
        CFStreamError stream_error;
        if (!CFHostStartInfoResolution(host, kCFHostAddresses, &stream_error)) {
            NSLog(@"Failed to resolve IP address for %@ [%ld, %d]",
                  address, stream_error.domain, stream_error.error);
            CFRelease(host);
            return nil;
        }
        
        Boolean has_been_resolved = false;
        CFArrayRef addresses = CFHostGetAddressing(host, &has_been_resolved);
        if (!has_been_resolved) {
            NSLog(@"Failed to get addresses for %@", address);
            CFRelease(host);
            return nil;
        }
        size_t addresses_count = CFArrayGetCount(addresses);
        
        for (size_t i = 0; i < addresses_count; i++) {
            CFDataRef address = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            // make a copy that we can futz with
            CFDataRef address_info = CFDataCreateCopy(kCFAllocatorDefault, address);
            int pf_version = PF_INET6;
            
            if (CFDataGetLength(address) == sizeof(struct sockaddr_in6)) {
                struct sockaddr_in6* addr =
                (struct sockaddr_in6*)CFDataGetBytePtr(address_info);
                addr->sin6_port = htons(port);
                pf_version = PF_INET6;
            }
            else if (CFDataGetLength(address) == sizeof(struct sockaddr_in)) {
                struct sockaddr_in* addr =
                (struct sockaddr_in*)CFDataGetBytePtr(address_info);
                addr->sin_port = htons(port);
                pf_version = PF_INET;
            }
            else {
                // leak memory because this exception should not be caught
                [NSException raise:NSInternalInconsistencyException
                            format:@"Got an address of weird length: %@",
                 (NSData*)address];
            }
            self->socket = CFSocketCreate(kCFAllocatorDefault,
                                          pf_version,
                                          SOCK_DGRAM,
                                          IPPROTO_UDP,
                                          kCFSocketNoCallBack,
                                          NULL, // callback function
                                          NULL); // callback context
            // completely bail
            if (!self->socket) {
                NSLog(@"Failed to allocate socket for statsd");
                CFRelease(address_info);
                CFRelease(host);
                return NULL;
            }
            
            // 1 second of timeout is more than enough, UDP "connect" should
            // only need to set a couple of things in kernel land
            switch (CFSocketConnectToAddress(self->socket, address_info, 1)) {
                case kCFSocketSuccess:
                    CFRelease(address_info);
                    CFRelease(host);
                    return self;
                    
                case kCFSocketError:
                    if (i == (addresses_count - 1))
                        NSLog(@"Failed to connect to all addresses of %@",
                              address);
                    CFRelease(socket);
                    CFRelease(address_info);
                    continue;
                    
                case kCFSocketTimeout:
                default:
                    CFRelease(socket);
                    CFRelease(address_info);
                    CFRelease(host);
                    [NSException raise:NSInternalInconsistencyException
                                format:@"Somehow timed out performing UDP connect"];
                    return nil;
            }
            
        }
        CFRelease(host);
    }
    
    return nil;
}

- (void)dealloc {
    self.namespace = nil;
    
    if (self->socket) {
        CFSocketInvalidate(self->socket);
        CFRelease(self->socket);
        self->socket = NULL;
    }
    
    [super dealloc];    
}

- (void)send:(NSString *)command {
    
    CFSocketError send_error = CFSocketSendData(self->socket,
                                                NULL,
                                                (CFDataRef)[command dataUsingEncoding:NSASCIIStringEncoding],
                                                1);
    if (send_error)
        NSLog(@"SendData failed: %ldl", send_error);
    
}

#pragma mark Public Methods

- (void)recordCount:(NSString *)stat value:(NSUInteger)value {
    NSString * command = [NSString stringWithFormat:@"%@.%@:%ld|c", self->namespace, stat, value];
    [self send:command];
    
}
- (void)recordSample:(NSString *)stat value:(NSUInteger)value interval:(float)interval {
    NSString * command = [NSString stringWithFormat:@"%@.%@:%ld|c|@%.2f", self->namespace, stat, value, interval];
    [self send:command];
}
- (void)recordTimeing:(NSString *)stat value:(NSUInteger)time {
    NSString * command = [NSString stringWithFormat:@"%@.%@:%ld|ms", self->namespace, stat, time];
    [self send:command];
}
- (void)setGauge:(NSString *)stat value:(NSInteger)value {
    NSString * command = [NSString stringWithFormat:@"%@.%@:%ld|g", self->namespace, stat, value];
    [self send:command];
}
- (void)adjustGauge:(NSString *)stat value:(NSInteger)value {
    NSString * command = [NSString stringWithFormat:@"%@.%@:%@%ld|g", self->namespace, stat, value < 0? @"" : @"+", value];
    [self send:command];
}
@end
