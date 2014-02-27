
//
//  XHLocationManager.m
//  业务员管家iPhone
//
//  Created by Kris on 13-11-7.
//  Copyright (c) 2013年 郑州悉知信息技术有限公司. All rights reserved.
//

#import "XHLocationManager.h"
#import "CLLocation+YCLocation.h"

@interface XHLocationManager()
{
    CLGeocoder *geocoder;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^locationCompletionBlock)(CLLocation *, NSError *);
@property (nonatomic, copy) void (^geocodeCompletionBlock)(CLPlacemark *, NSError *);

@end

@implementation XHLocationManager

#pragma mark - lifecycle

- (id)init
{
	self = [super init];
    if (self != nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        geocoder = [[CLGeocoder alloc] init];
    }
    
	return self;
}

+ (XHLocationManager *)sharedManager
{
    static XHLocationManager *sharedManager = nil;
    static dispatch_once_t onceLocationManagerToken;
    dispatch_once(&onceLocationManagerToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
    
}

- (void)locationRequest:(XHLocationCompletionHandler)locationCompletionBlock reverseGeocodeCurrentLocation:(XHGeocodeCompletionHandler)geocodeCompletionBlock
{
    if([CLLocationManager locationServicesEnabled])
    {
        self.locationCompletionBlock = locationCompletionBlock;
        self.geocodeCompletionBlock = geocodeCompletionBlock;
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
    }else{
        NSError *error = [NSError errorWithDomain:@"com.xizhi.yewu" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"未开启定位服务.", NSLocalizedDescriptionKey, nil]];
        self.locationCompletionBlock = locationCompletionBlock;
        self.geocodeCompletionBlock = geocodeCompletionBlock;
        self.locationCompletionBlock(nil,error);
//        self.geocodeCompletionBlock(nil,error);
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    CLLocation * location = [locations lastObject];
    NSLog(@"OldLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
    location = [location locationMarsFromEarth];
    NSLog(@"NewLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
    self.locationCompletionBlock(location,nil);
    [self reverseGeocodeLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [manager stopUpdatingLocation];
    CLLocation * location = newLocation;
    NSLog(@"OldLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
    location = [location locationMarsFromEarth];
    NSLog(@"NewLocation %f %f", location.coordinate.latitude, location.coordinate.longitude);
    self.locationCompletionBlock(location,nil);
    [self reverseGeocodeLocation:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self.locationManager stopUpdatingLocation];
//    self.locationCompletionBlock(nil,error);
}

#pragma mark - Geocode Location

-(void)reverseGeocodeLocation:(CLLocation * )location
{
    @synchronized (self){
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error)
            {
                self.geocodeCompletionBlock(nil,error);
                return;
            }else{
                if (placemarks.count <= 0)
                {
                    NSError *error = [NSError errorWithDomain:@"com.xizhi.yewu" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"没有返回结果.", NSLocalizedDescriptionKey, nil]];
                    self.geocodeCompletionBlock(nil, error);
                }else{
                    NSLog(@"%@",placemarks);
                    CLPlacemark * placemark = [placemarks objectAtIndex:0];
                    self.geocodeCompletionBlock(placemark,nil);
                }
            }
        }];
    }
}



@end
