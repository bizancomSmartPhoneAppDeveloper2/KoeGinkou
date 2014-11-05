//
//  FirstViewController.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//
#import "SecondViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"



@interface FirstViewController : UIViewController<CLLocationManagerDelegate,MKAnnotation,MKMapViewDelegate>
//現在位置を管理するための変数
@property CLLocationManager *locationManager;
//緯度、経度の情報を格納するための変数
@property(nonatomic)CLLocationCoordinate2D coordinate;
//タイトルを持つ変数
@property(nonatomic,copy)NSString *title;
//サブタイトルを持つ変数
@property(nonatomic,copy)NSString *subtitle;
//初期化用のメソッド
//マップの変数
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end



