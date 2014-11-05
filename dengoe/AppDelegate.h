//
//  AppDelegate.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SecondViewController;
@class WebViewController;
@class bizanViewController;
@class tsurugisanViewController;

@interface AppDelegate : UIResponder<UIApplicationDelegate>{
    
    // グローバル変数(どのクラスからも参照できる変数の事、ここで変数を宣言する事で異なるクラス間でも変数をやりとりできます。)
    NSMutableArray *didRejon;//領域内のRejonをこの配列に格納する
}
@property (strong, nonatomic) UIWindow *window;
// ここに受け渡ししたい変数を宣言
@property (nonatomic, retain) NSMutableArray *didRejon;//上で宣言したグローバル変数をここにも書く必要があります

@end

