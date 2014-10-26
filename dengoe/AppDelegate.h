//
//  AppDelegate.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <UIKit/UIKit.h>

@class tableView;

@interface AppDelegate : UIResponder<UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
// ここに受け渡ししたい変数を宣言
@property (nonatomic,retain) NSString *userName_send;
@property (nonatomic,retain) NSString *date_send;


@end

