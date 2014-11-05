//
//  SecondViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "SecondViewController.h"
#import "AppDelegate.h"



@interface SecondViewController ()

@end

@implementation SecondViewController{
    AVAudioRecorder *avRecorder;//録音のために必要
    AVAudioSession *audioSession;//録音のために必要
    AVAudioPlayer *avPlayer;//音声再生のために必要
    BOOL rokuonStarting;//録音しているかどうか（yesかnoで返ってくる）
    NSInteger number;//サーバの徳島城公園のデータベースにすでにある音声データの数
    NSInteger bizan_number;//サーバの眉山のデータベースにすでにある音声データの数
    NSInteger tsurugisan_number;//サーバの文化の森のデータベースにすでにある音声データの数
    NSInteger now_number;//新しくサーバに保存する音声データの番号
    NSString *userNameString;//登録文
    NSString *filename;//ファイルの名前
    NSString *path;//サーバと通信する際に使うパス
    NSString *updateURL;
    NSMutableArray *inRejon;//領域内に入っている吟行所の配列
    NSMutableArray *buttonTitleArray;//サーバに送信するための３つのボタンを配列として入れておく
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    rokuonStarting = NO;//初期化
    //サーバ登録するボタンを初期化（いったん非表示にしておく）
    self.tokushimaTourokuImage.hidden = YES;
    self.bizanTourokuImage.hidden = YES;
    self.tsurugisanTourokuImage.hidden = YES;
    self.rokuonteisiLabel.hidden = YES;
    //マイク上の押すと録音しますというラベルは表示しておく
    self.labelONmike.hidden = NO;
    
    self.myTextField.delegate = self;//テキストフィールドのデリゲートを今回はselfにする。
    number = 0;
    //配列を空で生成（初期化）
    inRejon = [NSMutableArray array];
    
    //デリゲートに保存したを取得する
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate]; // デリゲート呼び出し
    //didRejonをinRejonに設定
    inRejon = appDelegate.didRejon;
    
    //配列を空で生成（初期化）
    buttonTitleArray = [NSMutableArray array];
    //配列に要素を代入しておく
    buttonTitleArray =
    [NSMutableArray arrayWithObjects:@"徳島城公園吟行地", @"眉山吟行地", @"文化の森吟行地", nil];
    //下方にあるrokuonStartHiddenを実行
    [self rokuonStartHidden];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//マイクボタンをクリックされるとこのメソッドが呼ばれる
- (IBAction)rokuonStart:(UIButton *)sender {
    //録音状態でないかどうか
    //もし録音中でないならば
    if (rokuonStarting == NO) {
        //押すと録音しますラベルは隠して、押すと停止しますボタンは表示させる
        self.labelONmike.hidden = YES;
        self.rokuonteisiLabel.hidden = NO;
        //録音中はマイク画像の透明度をなくす
        self.rokuonStartStopImage.alpha = 1;
        //AVAudioSessionを使えるように準備
        audioSession = [AVAudioSession sharedInstance];
        NSError *error = nil;
        // 使用している機種が録音に対応しているか
        //対応しているなら使えるよう準備
        if ([audioSession inputIsAvailable]) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        }
        //対応していないならログにエラーを表示
        if(error){
            NSLog(@"audioSession: %@ %d %@", [error domain], [error code], [[error userInfo] description]);
        }
        // 録音機能をアクティブにする
        [audioSession setActive:YES error:&error];
        // 録音ファイルパス
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDir = [filePaths objectAtIndex:0];
        //wavファイルとして保存する
        NSString *path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
        NSURL *recordingURL = [NSURL fileURLWithPath:path];
        NSDictionary *dic;
        //AVEncoderAudioQualityKey オーディオ品質を設定するキー?
        //AVEncoderBitRateKey オーディオビットレートを設定するキー?
        //AVSampleRateKey 周波数(ヘルツ)を設定するキー?(このキーの値が小さいほどデータのサイズは小さくなる?)
        //AVNumberOfChannelsKey　チャネルの数を設定するキー?
        dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:AVAudioQualityLow],AVEncoderAudioQualityKey,
               [NSNumber numberWithInt:16],
               AVEncoderBitRateKey,
               [NSNumber numberWithInt: 1],
               AVNumberOfChannelsKey,
               [NSNumber numberWithFloat:100.0],
               AVSampleRateKey,
               nil];
        //AVAudioRecorderを使う準備
        avRecorder = [[AVAudioRecorder alloc] initWithURL:recordingURL settings:dic error:&error];
        //エラーならログにエラーを表示
        if(error){
            NSLog(@"patherror = %@",error);
            return;
        }
        //録音開始
        [avRecorder record];
        rokuonStarting = YES;//録音中なのでyesを代入
    }
    //録音状態であるかどうか
    //現在録音中にマイクボタンを押された場合
    else if(rokuonStarting == YES){
        //マイク上の録音ラベルを表示
        self.labelONmike.hidden = NO;
        //マイク上の停止ラベルを表示
        self.rokuonteisiLabel.hidden = YES;
        //マイク画像の透明度を半透明にする
        self.rokuonStartStopImage.alpha = 0.3;
        //正常に録音が完了したらアラートで知らせる
        [[[UIAlertView alloc] initWithTitle:@"完了"
                                    message:@"正常に句の録音が完了しました。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        //録音をやめる
        [avRecorder stop];
        rokuonStarting = NO;//録音停止したのでnoを代入しておく
        //音声ファイルを保存するためのパスを作っておく
        NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *documentDir = [filePaths objectAtIndex:0];
        path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
    }
}

//録音した音声を視聴する（再生ボタンが押されるとこのメソッドが呼ばれる）
- (IBAction)rokuonListen:(UIButton *)sender {
    
    //AVAudioSessionを準備
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
    // 録音ファイルパス
    NSArray *filePaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDir = [filePaths objectAtIndex:0];
    //rec.wavファイルがあるパスの文字列を格納
    NSString *path = [documentDir stringByAppendingPathComponent:@"rec.wav"];
    NSURL *recordingURL = [NSURL fileURLWithPath:path];
    
    //AVAudioPlayerを準備する
    avPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:recordingURL error:nil];
    //AVAudioPlayerの音量調整
    avPlayer.volume=1.0;
    //再生
    [avPlayer play];
}

//サーバの徳島城公園データベースに登録するボタンを押されたらこのメソッドが呼ばれる
- (IBAction)tourokuButton:(UIButton *)sender {
    //もしテキストフィールドにまだ登録分が入力されていないなら、アラートで知らせる
    if (userNameString == nil) {
        [[[UIAlertView alloc] initWithTitle:@"エラー"
                                    message:@"登録文を入力してください"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        
    }else {
        //すでにテキストフィールドに登録分が入力されているならば
        NSLog(@"徳島城公園吟行地へ登録クリックされました");
        //徳島城公園データベースにすでに保存されている音声ファイルの数を調べる
        NSURL *suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/sub_listen_dengoe.php"];
        //まずはNSData型で返ってくるのでいったん保存
        NSData *urldata = [NSData dataWithContentsOfURL:suburl];
        //NSDataの中に書いてある音声ファイルの数をまず文字列として変換
        NSString *numstr = [[NSString alloc]initWithData:urldata encoding:NSUTF8StringEncoding];
        NSLog(@"徳島城公園%@",numstr);
        //そして文字列としての音声ファイルの数をint型に変換
        number = [numstr intValue];
        //すでにデータベースに保存されている音声ファイルの数をログで確認
        NSLog(@"徳島城公園吟行地のテーブルのカウント数%d",number);
        
        //今からサーバに音声ファイルをアップロードする、アップロード先はこのurl
        updateURL = @"http://sayaka-sawada.main.jp/keijiban/listen_dengoe.php";
        now_number = number;//現在のファイル数に、データベースに保存されているファイル数を代入
        [self update];//録音した音声ファイルをアップロードする（下方にあるupdateメソッドを実行）
        //正常にアップロードされたならば、アラートで知らせる
        [[[UIAlertView alloc] initWithTitle:@"完了"
                                    message:@"正常に句が投稿されました"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        
        //徳島城公園の音声ファイルを置いているwebViewに遷移
        WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
        [self presentViewController:webView animated:YES completion:nil];
    }
}


//サーバの眉山データベースに登録するボタンを押されたらこのメソッドが呼ばれる
- (IBAction)bizantourokuButton:(UIButton *)sender {
    
    //上記の徳島城公園の場合のメソッドと内容は同じです
    
    if (userNameString == nil) {
        [[[UIAlertView alloc] initWithTitle:@"エラー"
                                    message:@"登録文を入力してください"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
    }else {
        NSLog(@"眉山吟行地へ登録クリックされました");
        //このurlは眉山専用です
        NSURL *bizan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/bizan_sub_listen_dengoe.php"];
        NSData *bizan_urldata = [NSData dataWithContentsOfURL:bizan_suburl];
        NSString *bizan_numstr = [[NSString alloc]initWithData:bizan_urldata encoding:NSUTF8StringEncoding];
        NSLog(@"眉山%@",bizan_numstr);
        bizan_number = [bizan_numstr intValue];
        now_number = bizan_number;
        //このurlは眉山専用です
        updateURL = @"http://sayaka-sawada.main.jp/keijiban/bizan_listen_dengoe.php";
        [self update];
        
        [[[UIAlertView alloc] initWithTitle:@"完了"
                                    message:@"正常に句が投稿されました。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        
        
        //bizanwebViewに遷移,viewcontrollerこのは眉山専用です
        bizanViewController *bizan_webView = [self.storyboard instantiateViewControllerWithIdentifier:@"bizanWebView"];
        [self presentViewController:bizan_webView animated:YES completion:nil];
    }
}

//サーバの文化の森データベースに登録するボタンを押されたらこのメソッドが呼ばれる
- (IBAction)tsurugisantourokuButton:(UIButton *)sender {
    
    //上記の徳島城公園の場合のメソッドと内容は同じです
    
    if (userNameString == nil) {
        [[[UIAlertView alloc] initWithTitle:@"エラー"
                                    message:@"登録文を入力してください"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        
    }else {
        NSLog(@"文化の森吟行地へ登録クリックされました");
        //このurlは眉山専用です
        NSURL *tsurugisan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/tsurugisan_sub_listen_dengoe.php"];
        NSData *tsurugisan_urldata = [NSData dataWithContentsOfURL:tsurugisan_suburl];
        NSString *tsurugisan_numstr = [[NSString alloc]initWithData:tsurugisan_urldata encoding:NSUTF8StringEncoding];
        NSLog(@"文化の森%@",tsurugisan_numstr);
        tsurugisan_number = [tsurugisan_numstr intValue];
        now_number = tsurugisan_number;
        //このurlは眉山専用です
        updateURL = @"http://sayaka-sawada.main.jp/keijiban/tsurugisan_listen_dengoe.php";
        [self update];
        
        [[[UIAlertView alloc] initWithTitle:@"完了"
                                    message:@"正常に句が投稿されました。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
        //tsurugisanwebViewに遷移,このviewcontrollerは文化の森専用です
        tsurugisanViewController *tsurugisan_webView = [self.storyboard instantiateViewControllerWithIdentifier:@"tsurugisanWebView"];
        [self presentViewController:tsurugisan_webView animated:YES completion:nil];
    }
}

//テキストフィールドがクリックされるとこのメソッドが呼ばれます
- (IBAction)userName:(UITextField *)sender {
}

//テキストフィールドのキーボードでリターンが押された時にこのメソッドが呼ばれる
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];//キーボードを片付けます
    userNameString = self.myTextField.text;//テキストフィールドに入力された文字列をuserNameStringに代入します、この文字列はサーバに送りデータベースに保存します
    NSLog(@"%@",userNameString);//ログで確認
    return NO;
}

//音声ファイルをサーバにアップロードします
-(void)update{
    //パスからデータを取得
    NSData *musicdata = [[NSData alloc]initWithContentsOfFile:path];
    //ファイルをサーバーにアップするためのプログラムのURLを生成
    NSURL *url = [NSURL URLWithString:updateURL];
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
    
    //現在の日時を取得する（音声ファイルアップロード日時もサーバに保存します）
    [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    self.dateString = [formatter stringFromDate:date];
    //送るファイル名をdateと設定
    [body appendData:[@"Content-Disposition: form-data; name=\"date\"\r\n\r\n"  dataUsingEncoding:NSUTF8StringEncoding]];
    //現在日時の文字列データ追加
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", self.dateString] dataUsingEncoding:NSUTF8StringEncoding]];
    //bodyの最初にバウンダリ文字列(仕切線)を追加
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //テキストフィールドに入力された文字列をサーバに送信します
    //送るファイル名をusernameと設定
    [body appendData:[@"Content-Disposition: form-data; name=\"username\"\r\n\r\n"  dataUsingEncoding:NSUTF8StringEncoding]];
    //文字列データ追加
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", userNameString] dataUsingEncoding:NSUTF8StringEncoding]];
    //bodyの最初にバウンダリ文字列(仕切線)を追加
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    //サーバー側に送るファイルの項目名をsample
    //送るファイル名をsaple.mp3と設定
    now_number++;//ファイル数を設定（すでにサーバにあるファイル数プラス１）

    //htmlを生成させます
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sample\"; filename=\"%dsample.mp3\"\r\n",now_number]  dataUsingEncoding:NSUTF8StringEncoding]];
    //filenameは「ファイル数sample.mp3」とする
    filename = [NSString stringWithFormat:@"%dsample.mp3",now_number];
    NSLog(@"%d",now_number);
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
    NSLog(@"%@",datastring);
}

-(void)rokuonStartHidden{
    //領域内のサーバに音声ファイルをアップするボタンを表示する（領域外のボタンは非表示のまま）
    for (int i = 0; i < inRejon.count; i++) {
        //もし徳島城公園吟行地が領域内なら
        if ([inRejon containsObject:@"徳島城公園吟行地"]) {
            //徳島城公園吟行地のアップロードボタンを表示
            self.tokushimaTourokuImage.hidden = NO;
        }else{
            nil;
        }
        //もし眉山吟行地が領域内なら
        if ([inRejon containsObject:@"眉山吟行地"]) {
            //眉山吟行地のアップロードボタンを表示
            self.bizanTourokuImage.hidden = NO;
        }else{
            nil;
        }
        //もし文化の森吟行地が領域内なら
        if ([inRejon containsObject:@"文化の森吟行地"]) {
            //文化の森吟行地のアップロードボタンを表示
            self.tsurugisanTourokuImage.hidden = NO;
        }else{
            nil;
        }
    }
}
@end
