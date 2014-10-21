//
//  SecondViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "SecondViewController.h"


@interface SecondViewController ()

@end

@implementation SecondViewController{
    AVAudioRecorder *avRecorder;
    AVAudioSession *audioSession;
    AVAudioPlayer *avPlayer;
    BOOL rokuonStarting;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rokuonStart:(UIButton *)sender {
    if (rokuonStarting == NO) {
    audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    // 使用している機種が録音に対応しているか
    if ([audioSession inputIsAvailable]) {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    }
    if(error){
        NSLog(@"audioSession: %@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
    // 録音機能をアクティブにする
    [audioSession setActive:YES error:&error];
    if(error){
        NSLog(@"audioSession: %@ %ld %@", [error domain], [error code], [[error userInfo] description]);
    }
    
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.caf"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    // 録音中に音量をとる場合はYES
    //    AvRecorder.meteringEnabled = YES;
    
    avRecorder = [[AVAudioRecorder alloc] initWithURL:recordingURL settings:nil error:&error];
    
    if(error){
        NSLog(@"error = %@",error);
        return;
    }
    avRecorder.delegate=self;
    //    ５秒録音して終了する場合
    //    [avRecorder recordForDuration: 5.0];
    [avRecorder record];
        rokuonStarting = YES;
        self.rokuonStartStopImage.alpha = 1;

    }else if(rokuonStarting == YES){
        [avRecorder stop];
        rokuonStarting = NO;
        self.rokuonStartStopImage.alpha = 0.5;
    }
}

- (IBAction)rokuonListen:(UIButton *)sender {
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.caf"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    //再生
    avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:recordingURL error:nil];
    avPlayer.delegate = self;
    avPlayer.volume=1.0;
    [avPlayer play];
}

- (IBAction)tourokuButton:(UIButton *)sender {
    //デリゲート？
    //現在地を取得
    //現在地にピンを立てて
    //現在地ピンのアノケーションビューに録音再生ボタンと録音タイトルを表示
    [self.delegate didTouroku];
    NSLog(@"クリックされました");
}

- (IBAction)userName:(UITextField *)sender {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    self.userName = self.myTextField.text;
    
    //userNameを他クラスから参照するので、appに保存する
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; // デリゲート呼び出し
    appDelegate.userName_send = self.userName; // デリゲートプロパティに値代入
    return NO;
    
    
}
@end
