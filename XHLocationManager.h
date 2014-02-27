//
//  XHLocationManager.h
//  业务员管家iPhone
//
//  Created by Kris on 13-11-7.
//  Copyright (c) 2013年 郑州悉知信息技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^XHGeocodeCompletionHandler)(CLPlacemark *placemark, NSError *error);
typedef void (^XHLocationCompletionHandler)(CLLocation *location, NSError *error);

@interface XHLocationManager : NSObject<CLLocationManagerDelegate>

+ (XHLocationManager *)sharedManager;
- (void)locationRequest:(XHLocationCompletionHandler)locationCompletionBlock reverseGeocodeCurrentLocation:(XHGeocodeCompletionHandler)geocodeCompletionBlock;

@end

/*--------------------------------------使用方法--------------------------------------------*/

/*
    [[XHLocationManager sharedManager] locationRequest:^(CLLocation *location, NSError *error) {
        if (error == nil) {
            NSLog(@"%@",location);
        } else {
            NSLog(@"%@",error);
        }
    } reverseGeocodeCurrentLocation:^(CLPlacemark *placemark, NSError *error) {
        if (error == nil) {
            NSLog(@"%@",placemark);
        } else {
            NSLog(@"%@",error);
        }
    }];
*/
