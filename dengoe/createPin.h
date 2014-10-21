//
//  createPin.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface createPin : NSObject<MKAnnotation>{
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
    MKPinAnnotationColor *pinColor;
}

//緯度、経度の情報を格納するための変数
@property(nonatomic)CLLocationCoordinate2D coordinate;
//タイトルを持つ変数
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subtitle;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *open;
@property(nonatomic,copy)NSString *close;
@property(nonatomic,copy)NSString *coupon_urls;
@property(nonatomic,copy)NSString *price;
@property(nonatomic,copy)NSString *parking;


//初期化用のメソッド
-(id)initwithCoordinate:(CLLocationCoordinate2D)co;
@end
