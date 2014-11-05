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

//テキストフィールドのデリゲートになります（テキストフィールドはこのviewcontroller内にあります）
@interface SecondViewController : UIViewController<UITextFieldDelegate>
- (IBAction)rokuonStart:(UIButton *)sender;//録音するボタン（マイク）
- (IBAction)rokuonListen:(UIButton *)sender;//録音した音声を視聴する（再生ボタン）
- (IBAction)bizantourokuButton:(UIButton *)sender;//眉山のサーバに登録するボタン
- (IBAction)tsurugisantourokuButton:(UIButton *)sender;//剣山のサーバに登録するボタン
- (IBAction)tourokuButton:(UIButton *)sender;//徳島城公園のサーバに登録するボタン
@property (weak, nonatomic) IBOutlet UIButton *rokuonStartStopImage;//マイクの画像
- (IBAction)userName:(UITextField *)sender;//テキストフィールドに何か入力されたらこのメソッドで受け取る
@property (weak, nonatomic) IBOutlet UITextField *myTextField;
@property NSString *userName;//テキストフィールドに書き込まれた文字
@property NSString *dateString;//音声と登録文をアップする時の日付
@property (weak, nonatomic) IBOutlet UILabel *labelONmike;//マイク上にあるラベル
@property (weak, nonatomic) IBOutlet UIButton *tokushimaTourokuImage;//徳島城公園にアップするボタンのイメージ画像
@property (weak, nonatomic) IBOutlet UIButton *bizanTourokuImage;//眉山にアップするボタンのイメージ画像

@property (weak, nonatomic) IBOutlet UIButton *tsurugisanTourokuImage;//文化の森にアップするボタンのイメージ画像

@property (weak, nonatomic) IBOutlet UILabel *rokuonteisiLabel;//マイクの画像上にある停止ラベル

@end

