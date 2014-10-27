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
    NSInteger number;
    
}

- (void)viewDidLoad {
    rokuonStarting = NO;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myTextField.delegate = self;
    number = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rokuonStart:(UIButton *)sender {
    //録音状態でないかどうか
    if (rokuonStarting == NO) {
        self.rokuonStartStopImage.alpha = 1;
        audioSession = [AVAudioSession sharedInstance];
        NSError *error = nil;
        // 使用している機種が録音に対応しているか
        if ([audioSession inputIsAvailable]) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        }
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        }
        // 録音機能をアクティブにする
        [audioSession setActive:YES error:&error];
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        }
        
        // 録音ファイルパス
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask,YES);
        NSString *documentDir = [filePaths objectAtIndex:0];
        //wavファイルとして保存する
        NSString *path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
        NSURL *recordingURL = [NSURL fileURLWithPath:path];
        avRecorder = [[AVAudioRecorder alloc] initWithURL:recordingURL settings:nil error:&error];
        
        if(error){
            NSLog(@"patherror = %@",error);
            return;
        }
        //録音開始
        
        [avRecorder record];
        rokuonStarting = YES;
        
    }
    //録音状態であるかどうか
    else if(rokuonStarting == YES){
        self.rokuonStartStopImage.alpha = 0.3;

        //録音をやめる
        [avRecorder stop];
        rokuonStarting = NO;
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                 NSUserDomainMask,YES);
        NSString *documentDir = [filePaths objectAtIndex:0];
        NSString *path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
        
        [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
        NSDate *date = [NSDate date];
        self.dateString = [formatter stringFromDate:date];
        

        
        //パスからデータを取得
        NSData *musicdata = [[NSData alloc]initWithContentsOfFile:path];
        //ファイルをサーバーにアップするためのプログラムのURLを生成
        NSURL *url = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/listen_dengoe.php"];
        //urlをもとにしたリクエストを生成
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        //リクエストメッセージのbody部分を作るための変数
        NSMutableData *body = [NSMutableData data];
        //バウンダリ文字列(仕切線)を格納している変数
        NSString *boundary = @"---------------------------168072824752491622650073";
        //Content-typeヘッダに設定する情報を格納する変数
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        //POST形式の通信を行うようにする
        [request setHTTPMethod:@"POST"];
        //bodyの最初にバウンダリ文字列(仕切線)を追加
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //サーバー側に送るファイルの項目名をsample
        
        
        //送るファイル名をdateと設定
        [body appendData:[@"Content-Disposition: form-data; name=\"date\"\r\n\r\n"  dataUsingEncoding:NSUTF8StringEncoding]];
        //現在日時の文字列データ追加
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", self.dateString] dataUsingEncoding:NSUTF8StringEncoding]];
        //bodyの最初にバウンダリ文字列(仕切線)を追加
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //サーバー側に送るファイルの項目名をsample
        //送るファイル名をsaple.mp3と設定
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sample\"; filename=\"%dsample.mp3\"\r\n",number]  dataUsingEncoding:NSUTF8StringEncoding]];
        number++;
        NSLog(@"%d",number);
        //送るファイルのデータのタイプを設定する情報を追加
        [body appendData:[@"Content-Type: audio/mpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        //音楽ファイルのデータを追加
        [body appendData:musicdata];
        NSLog(@"録音のデータサイズ%dバイト",musicdata.length);
        //最後にバウンダリ文字列を追加
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        //ヘッダContent-typeに情報を追加
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        //リクエストのボディ部分に変数bodyをセット
        [request setHTTPBody:body];
        NSURLResponse *response;
        NSError *err = nil;
        //サーバーとの通信を行う
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        //サーバーからのデータを文字列に変換
        NSString *datastring = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@",datastring);
    }
    
}

- (IBAction)rokuonListen:(UIButton *)sender {
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    //rec.wavファイルがあるパスの文字列を格納
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:recordingURL error:nil];
    avPlayer.volume=1.0;
    //再生
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
    [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    self.dateString = [formatter stringFromDate:date];
    NSLog(@"%@",self.dateString);
    appDelegate.date_send = self.dateString;
    return NO;
    
    
}
@end
