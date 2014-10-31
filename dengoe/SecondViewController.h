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

@interface SecondViewController : UIViewController<UITextFieldDelegate>
- (IBAction)rokuonStart:(UIButton *)sender;
- (IBAction)rokuonListen:(UIButton *)sender;
- (IBAction)bizantourokuButton:(UIButton *)sender;
- (IBAction)tsurugisantourokuButton:(UIButton *)sender;

- (IBAction)tourokuButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *rokuonStartStopImage;
- (IBAction)userName:(UITextField *)sender;
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property NSString *userName;
@property NSString *dateString;
@property (weak, nonatomic) IBOutlet UILabel *labelONmike;
@property (weak, nonatomic) IBOutlet UIButton *tokushimaTourokuImage;
@property (weak, nonatomic) IBOutlet UIButton *bizanTourokuImage;
@property (weak, nonatomic) IBOutlet UIButton *tsurugisanTourokuImage;
@property (weak, nonatomic) IBOutlet UILabel *rokuonteisiLabel;

@end

