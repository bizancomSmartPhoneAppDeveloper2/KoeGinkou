//
//  CustomAnnotation.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>{
    
CLLocationCoordinate2D coordinate;
NSString *title;
NSString *subtitle;
NSString *sample;
}
//緯度、経度の情報を格納するための変数
@property(nonatomic)CLLocationCoordinate2D coordinate;
//タイトルを持つ変数
@property(nonatomic,copy)NSString *title;
//サブタイトルを持つ変数
@property(nonatomic,copy)NSString *subtitle;
//タイトルとサブタイトル以外の情報を持つための変数
@property(nonatomic,copy)NSString *sample;
//初期化用のメソッド
-(id)initwithCoordinate:(CLLocationCoordinate2D)co;

@end
