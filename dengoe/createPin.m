//
//  createPin.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "createPin.h"

@implementation createPin
//アクセサメソッドを自動生成
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize name;
@synthesize open;
@synthesize close;
@synthesize coupon_urls;
@synthesize price;
@synthesize parking;



//初期化用のメソッド
-(id)initwithCoordinate:(CLLocationCoordinate2D)co{
    coordinate = co;
    return self;
}
@end
