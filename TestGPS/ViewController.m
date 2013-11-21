//
//  ViewController.m
//  TestGPS
//
//  Created by Lucky Ji on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize lat;
@synthesize llong;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.m_map.showsUserLocation = YES;//显示ios自带的我的位置显示
    
}

- (void)viewDidUnload
{
    [self setLat:nil];
    [self setLlong:nil];
    [self setOffLat:nil];
    [self setOffLog:nil];
    [self setM_map:nil];
    [self setM_locationName:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)OpenGPS:(id)sender {
    if ([CLLocationManager locationServicesEnabled]) { // 检查定位服务是否可用
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter=0.5;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation]; // 开始定位
    }
    
    NSLog(@"GPS 启动");
}

- (IBAction)OpenZDOZ:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.zdoz.net"];
    [[UIApplication sharedApplication]openURL:url];
}

// 定位成功时调用
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation 
{
    CLLocationCoordinate2D mylocation = newLocation.coordinate;//手机GPS
    lat.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.latitude];
    llong.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.longitude];
    
    mylocation = [self zzTransGPS:mylocation];///火星GPS
    self.offLat.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.latitude];
    self.offLog.text = [[NSString alloc]initWithFormat:@"%lf",mylocation.longitude];
    //显示火星坐标
    [self SetMapPoint:mylocation];
    
    /////////获取位置信息
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray* placemarks,NSError *error)
    {
        if (placemarks.count >0   )
        {
            CLPlacemark * plmark = [placemarks objectAtIndex:0];
            
            NSString * country = plmark.country;
            NSString * city    = plmark.locality;
            
            
            NSLog(@"%@-%@-%@",country,city,plmark.name);
            self.m_locationName.text =plmark.name;
        }
        
        NSLog(@"%@",placemarks);
        
    }];
    
    //[geocoder release];
    
}
// 定位失败时调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
}

-(CLLocationCoordinate2D)zzTransGPS:(CLLocationCoordinate2D)yGps
{
    
    Location loc;
    loc.lat = yGps.latitude;
    loc.lng = yGps.longitude;
    
    loc=transformFromWGSToGCJ(loc);
    yGps.latitude = loc.lat;
    yGps.longitude = loc.lng;
    return yGps;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.lat resignFirstResponder];
    [self.llong resignFirstResponder];
    return YES;
}

-(void)SetMapPoint:(CLLocationCoordinate2D)myLocation
{

    POI* m_poi = [[POI alloc]initWithCoords:myLocation];
    
    [self.m_map addAnnotation:m_poi];
    
    MKCoordinateRegion theRegion = { {0.0, 0.0 }, { 0.0, 0.0 } };
    theRegion.center=myLocation;
    [self.m_map setZoomEnabled:YES];
    [self.m_map setScrollEnabled:YES];
    theRegion.span.longitudeDelta = 0.01f;
    theRegion.span.latitudeDelta = 0.01f;
    [self.m_map setRegion:theRegion animated:YES];
}
- (IBAction)TouchZhuan:(id)sender {
    CLLocationCoordinate2D mylocation;
    mylocation.latitude = self.lat.text.doubleValue;
    mylocation.longitude = self.llong.text.doubleValue;
    
    CLLocationCoordinate2D mylocation2 = [self zzTransGPS:mylocation];///火星GPS
    self.offLat.text = [[NSString alloc]initWithFormat:@"%lf",mylocation2.latitude];
    self.offLog.text = [[NSString alloc]initWithFormat:@"%lf",mylocation2.longitude];
    //显示火星坐标
    [self SetMapPoint:mylocation2];
}
@end


@implementation POI

@synthesize coordinate,subtitle,title;

- (id) initWithCoords:(CLLocationCoordinate2D) coords{
    
    self = [super init];
    
    if (self != nil) {
        
        coordinate = coords;
        
    }
    
    return self;
    
}

//- (void) dealloc
//
//{
//    [title release];
//    [subtitle release];
//    [super dealloc];
//}

@end
