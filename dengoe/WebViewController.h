//
//  WebViewController.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/25.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
//このクラスはWebViewControllerが表示される時に実行されます

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
