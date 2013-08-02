//
//  UIDevice(Identifier).m
//  UIDeviceAddition
//
//  Created by Georg Kitz on 20.08.11.
//  Copyright 2011 Aurora Apps. All rights reserved.
//

#import "UIDevice+TBHelper.h"

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>

@interface UIDevice (Private)

- (NSString *)macaddress;

@end

@implementation UIDevice (TBHelper)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
- (NSString *)macaddress {

    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;

    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;

    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }

    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }

    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }

    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        printf("Error: sysctl, take 2");
        return NULL;
    }

    ifm = (struct if_msghdr *) buf;
    sdl = (struct sockaddr_dl *) (ifm + 1);
    ptr = (unsigned char *) LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                                     *ptr, *(ptr + 1), *(ptr + 2), *(ptr + 3), *(ptr + 4), *(ptr + 5)];
    free(buf);

    return outstring;
}


- (NSString *)sha1ForString:(NSString *)str {

    if (self == nil || [str length] == 0)
        return nil;

    const char *value = [str UTF8String];

    unsigned char outputBuffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(value, strlen(value), outputBuffer);

    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_SHA1_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }

    return outputString;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (NSString *)getUniqueDeviceIdentifier {
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

    NSString *stringToHash = [NSString stringWithFormat:@"%@%@", macaddress, bundleIdentifier];
    NSString *uniqueDeviceIdentifier = [self sha1ForString:stringToHash];

    return uniqueDeviceIdentifier;
}

- (NSString *)getUniqueGlobalDeviceIdentifier {
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueGlobalDeviceIdentifier = [self sha1ForString:macaddress];

    return uniqueGlobalDeviceIdentifier;
}

@end
