//
//  CustomAnnotation.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
//アクセサメソッドを自動生成
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize sample;

//初期化用のメソッド
-(id)initwithCoordinate:(CLLocationCoordinate2D)co{
    coordinate = co;
    return self;
}
@end

