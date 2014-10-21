//
//  SecondViewController.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@protocol rokuonViewDelegate<NSObject>//デリゲートすることを宣言
-(void)didTouroku;//デリゲートメソッド
@end

@interface SecondViewController : UIViewController<UITextFieldDelegate>
- (IBAction)rokuonStart:(UIButton *)sender;
- (IBAction)rokuonListen:(UIButton *)sender;
@property id<rokuonViewDelegate> delegate;

- (IBAction)tourokuButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *rokuonStartStopImage;
- (IBAction)userName:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property NSString *userName;
@property NSString *dateString;
@end

