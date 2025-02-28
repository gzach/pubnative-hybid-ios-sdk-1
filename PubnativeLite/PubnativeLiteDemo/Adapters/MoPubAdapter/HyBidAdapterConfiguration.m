//
//  Copyright © 2019 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "HyBidAdapterConfiguration.h"

NSString *const HyBidAdapterConfigurationNetworkName = @"pubnative";
NSString *const HyBidAdapterConfigurationAdapterVersion = @"2.6.1";
NSString *const HyBidAdapterConfigurationNetworkSDKVersion = @"2.6.1";
NSString *const HyBidAdapterConfigurationAppTokenKey = @"pubnative_appToken";

@implementation HyBidAdapterConfiguration

- (NSString *)adapterVersion {
    return HyBidAdapterConfigurationAdapterVersion;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return HyBidAdapterConfigurationNetworkName;

}

- (NSString *)networkSdkVersion {
    return HyBidAdapterConfigurationNetworkSDKVersion;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration
                                  complete:(void (^)(NSError * _Nullable))complete {
    if (configuration && [configuration objectForKey:HyBidAdapterConfigurationAppTokenKey]) {
        NSString *appToken = [configuration objectForKey:HyBidAdapterConfigurationAppTokenKey];
        [HyBid initWithAppToken:appToken completion:^(BOOL success) {
            complete(nil);
        }];
    } else {
        NSError *error = [NSError errorWithDomain:@"Native Network or Custom Event adapter was configured incorrectly."
                                             code:0
                                         userInfo:nil];
        complete(error);
    }
    
}

@end
