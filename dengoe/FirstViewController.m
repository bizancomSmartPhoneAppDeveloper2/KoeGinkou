//
//  FirstViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "FirstViewController.h"
#import "CustomAnnotation.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "bizanViewController.h"
#import "tsurugisanViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController{
    CLLocationDegrees latitude;//緯度
    CLLocationDegrees longitude;//経度
    CLLocationCoordinate2D co;//地図の真ん中
    CLLocationCoordinate2D coTokushimaeki;//徳島駅
    CLLocationCoordinate2D coBizan;//眉山
    CLLocationCoordinate2D coTsurugisan;//剣山
    NSString *urlstr;//まずはURLを文字列としてセットしなければならない
    NSURL *url;//URLを格納する変数
    NSURLRequest *request;//URL先のページに飛ぶようリクエストする準備
    NSData *data;//データを入れる変数
    NSString *name;
    AVAudioSession *audioSession;//音声を再生・録音するために必要な変数
    AVAudioPlayer *avPlayer;//音声を再生ために必要な変数
    MKCircle *circleTokushimaeki;//徳島駅を中心とした円を描くための変数
    MKCircle *circleBizan;//眉山を中心とした円を描くための変数
    MKCircle *circleTsurugisan;//剣山を中心とした円を描くための変数
    MKCoordinateRegion regionMap;
    CLRegion *grRegionTokushimaeki;//徳島駅を中心としたジオフェンス
    CLRegion *grRegionBizan;//眉山を中心としたジオフェンス
    CLRegion *grRegionTsurugisan;//剣山を中心としたジオフェンス
    NSMutableArray *inRejon;//現在領域内である吟行地を配列に格納
    NSString *stringinrejon;//inRejonの中身を確認するために使う変数
}

@synthesize locationManager;

//viewDidLoadされる前に呼ばれるメソッド
-(void)viewWillAppear:(BOOL)animated{
    //viewDidLoadされる前にアノテーションを準備しておく
    [self newAnnotation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //緯度経度を初期化
    latitude = 0;
    longitude = 0;
    //mapにはデリゲートが必要、今回は自分がデリゲート先になるのでself。
    [self.map setDelegate: self];
    //下方にあるlocationManagerMethodを実行
    [self locationManagerMethod];
    
    //配列を空で生成
    inRejon = [NSMutableArray array];
    
    // 2000mの範囲円を作成
    circleTokushimaeki = [MKCircle circleWithCenterCoordinate:coTokushimaeki radius: 2000.0];//徳島駅中心
    circleBizan = [MKCircle circleWithCenterCoordinate:coBizan radius: 2000.0];//眉山中心
    circleTsurugisan = [MKCircle circleWithCenterCoordinate:coTsurugisan radius: 2000.0];//剣山中心
    CLLocationDistance radiusOnMeter = 2000.0;//ジオフェンス監視領域は半径2000m
    
    //徳島駅を中心としたジオフェンスを作成
    grRegionTokushimaeki = [[CLRegion alloc] initCircularRegionWithCenter:coTokushimaeki radius:radiusOnMeter identifier:@"徳島城公園吟行地"];
    //徳島駅のジオフェンス監視を開始
    [self.locationManager startMonitoringForRegion:grRegionTokushimaeki];
    //眉山を中心としたジオフェンスを作成
    grRegionBizan = [[CLRegion alloc] initCircularRegionWithCenter:coBizan radius:radiusOnMeter identifier:@"眉山吟行地"];
    //眉山のジオフェンス監視を開始
    [self.locationManager startMonitoringForRegion:grRegionBizan];
    //剣山を中心としたジオフェンスを作成
    grRegionTsurugisan = [[CLRegion alloc] initCircularRegionWithCenter:coTsurugisan radius:radiusOnMeter identifier:@"文化の森吟行地"];
    //剣山のジオフェンス監視を開始
    [self.locationManager startMonitoringForRegion:grRegionTsurugisan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//アノテーションを追加してアノテーション(ピン)が表示されるときに呼ばれるメソッド
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //現在地の情報でないか
    if (annotation != self.map.userLocation) {
        //現在地でないならば
        NSString *pin = @"pin";
        //pinで示すリサイクル可能なアノテーションビューかnilが返ってくる
        MKAnnotationView *av = (MKAnnotationView*)[self.map dequeueReusableAnnotationViewWithIdentifier:pin];
        if (av == nil) {
            //もしまだアノテーションが一度も作られていないなら、anotetionとpinを用いて値を代入
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pin];
            //表示する画像を設定
            av.image = [UIImage imageNamed:@"haiku2.png"];
            //ピンをクリックしたときにピンの情報（タイトルとサブタイトル）を表示するようにする
            av.canShowCallout = YES;
        }
        //もしアノテーションが一度でも作られていたなら、アノテーションを返す
        return av;
    }else{
        //もし現在地ならば、何もしない
        return nil;
    }
}

//mapにアノテーションが追加されたらこのメソッドが呼ばれる
- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{
    // MAP上にあるアノテーションビューを全部取得する
    for (MKAnnotationView *annotationView in views) {
        //ボタンを作る
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // コールアウト（アノテーションを押すと出てくる吹き出し）の左側にボタンを追加する
        annotationView.leftCalloutAccessoryView = button;
    }
    
}

//アノテーションのコールアウトに追加したボタンがタップされるとこのメソッドが呼ばれる
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //領域内の吹き出しのボタンが押された場合はWebViewに遷移
    for (int i = 0; i < inRejon.count; i++) {
        //inRejon.count(領域内である吟行地の数)の回数、繰り返す
        //領域内である全ての吟行地のタイトルをログに書き出す
        NSLog(@"%@%@",view.annotation.title,[inRejon objectAtIndex:i]);}
    //もし領域内の吟行地があれば（領域内配列の中身とアノテーションタイトルが同じものがあれば）
    if ([inRejon containsObject:view.annotation.title]) {
        //もしそれが徳島城公園吟行地ならば
        if ([view.annotation.title isEqualToString:@"徳島城公園吟行地"]) {
            //徳島城公園吟行地のwebViewに遷移
            WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
            [self presentViewController:webView animated:YES completion:nil];
            
        }else if ([view.annotation.title isEqualToString:@"眉山吟行地"]) {
            //もしそれが眉山吟行地ならば
            //bizan_webViewに遷移
            //ストーリーボードにあるbizanWebViewと名前を付けたViewControllerに遷移
            bizanViewController *bizan_webView = [self.storyboard instantiateViewControllerWithIdentifier:@"bizanWebView"];
            [self presentViewController:bizan_webView animated:YES completion:nil];
            
        }else if ([view.annotation.title isEqualToString:@"文化の森吟行地"]) {
            //もしそれが眉山吟行地ならば
            //tsurugisanwebViewに遷移
            tsurugisanViewController *tsurugisan_webView = [self.storyboard instantiateViewControllerWithIdentifier:@"tsurugisanWebView"];
            //ストーリーボードにあるtsurugisanWebViewと名前を付けたViewControllerに遷移
            [self presentViewController:tsurugisan_webView animated:YES completion:nil];
            
        }
        
        //アノテーションの情報を取得
        NSLog(@"title: %@", view.annotation.title);//アノテーションのタイトル
        NSLog(@"subtitle: %@", view.annotation.subtitle);//アノテーションのサブタイトル
        NSLog(@"coord: %f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);//アノテーションの緯度と経度
    }else{
        //もし領域外の吹き出しのボタンが押された場合はアラートを表示
        [[[UIAlertView alloc] initWithTitle:@"領域外です"
                                    message:@"領域外のため只今閲覧・投稿できません。"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil]show];
    }
}

//現在地を取得
-(void)locationManagerMethod{
    
    self.locationManager = [[CLLocationManager alloc] init];
    //現在地を取得するにはデリゲートが必要。今回はself。
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        // iOS バージョンが 8 以上で、requestAlwaysAuthorization メソッドが
        // 利用できる場合
        
        // 位置情報測位の許可を求めるメッセージを表示する
        [self.locationManager requestAlwaysAuthorization];
        //      [self.locationManager requestWhenInUseAuthorization];
    } else {
        // iOS バージョンが 8 未満で、requestAlwaysAuthorization メソッドが
        // 利用できない場合
        
        // この方法で測位を開始する
        [self.locationManager startUpdatingLocation];
    }
}

//現在地を更新するメソッド
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // 位置情報測位の許可状態が「常に許可」または「使用中のみ」の場合、
        // 測位を開始する（iOS バージョンが 8 以上の場合のみ該当する）
        // ※iOS8 以上の場合、位置情報測位が許可されていない状態で
        // 　startUpdatingLocation メソッドを呼び出しても、何も行われない。
        [self.locationManager startUpdatingLocation];
        
    }
}

//現在地が更新されたら現在地の緯度と経度を取得
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    //最後に確認した現在地情報を格納
    CLLocation *location = [locations lastObject];
    NSLog(@"現在地経度%f 現在地緯度%f",
          location.coordinate.latitude,
          location.coordinate.longitude);
    //最新の現在地の緯度と経度を格納
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    
    //下方にあるdefaultMapSetteiを実行
    [self defaultMapSettei];
    //現在地更新をストップ
    [self.locationManager stopUpdatingLocation];
}

//現在地が取得できなかった時はアラートで知らせる
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"エラー"
                                message:@"位置情報が取得できませんでした。"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles: nil]show];
}

//デフォルトで表示しておきたいmapの設定をここで行う
-(void)defaultMapSettei{
    //デリゲートを自分自身に設定
    self.map.delegate = self;
    NSLog(@"中心経度%f 中心緯度%f",latitude,longitude);
    
    //地図の真ん中の位置を緯度と経度で設定
    co.latitude = latitude;
    co.longitude = longitude;
    
    //地図の縮尺を設定、coを中心に1000m四方で設定
    self.map.region = MKCoordinateRegionMakeWithDistance(co, 10000, 10000);
    //区画内の建物表示プロパティ、初期値NO
    [self.map setShowsBuildings:YES];
    //コンビニなどランドマークの表示プロパティ、初期値NO
    [self.map setShowsPointsOfInterest:YES];
    //ユーザの現在地表示プロパティ（表示のされ方は純正マップアプリを参照）初期値NO
    [self.map setShowsUserLocation:YES];
    
}

-(void)newAnnotation{
    NSInteger number;//サーバにすでに存在している徳島城公園の音声ファイルの数を格納
    NSURL *suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/sub_listen_dengoe.php"];//音声ファイルの数をこのURL先のサーバに問い合わせる
    NSData *urldata = [NSData dataWithContentsOfURL:suburl];//音声ファイルの数がNSData型で返ってくるのでとりあえずいったん格納
    NSString *numstr = [[NSString alloc]initWithData:urldata encoding:NSUTF8StringEncoding];//返ってきたNSDataから音声ファイルの数をまず文字列をして取り出す
    NSLog(@"徳島城公園%@",numstr);
    number = [numstr intValue];//文字列の数字をINT型に変換した
    
    //次は同じようにサーバにすでに存在している眉山の音声ファイルの数を調べる
    NSInteger bizan_number;
    NSURL *bizan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/bizan_sub_listen_dengoe.php"];//こちらは眉山の音声ファイルの数が入っているPHPのURL
    NSData *bizan_urldata = [NSData dataWithContentsOfURL:bizan_suburl];
    NSString *bizan_numstr = [[NSString alloc]initWithData:bizan_urldata encoding:NSUTF8StringEncoding];
    NSLog(@"眉山%@",bizan_numstr);
    bizan_number = [bizan_numstr intValue];
    
    //続いて同じく文化の森
    NSInteger tsurugisan_number;
    NSURL *tsurugisan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/tsurugisan_sub_listen_dengoe.php"];
    NSData *tsurugisan_urldata = [NSData dataWithContentsOfURL:tsurugisan_suburl];
    NSString *tsurugisan_numstr = [[NSString alloc]initWithData:tsurugisan_urldata encoding:NSUTF8StringEncoding];
    NSLog(@"文化の森%@",tsurugisan_numstr);
    tsurugisan_number = [tsurugisan_numstr intValue];
    
    //緯度と経度情報を格納する変数の値を変更
    coTokushimaeki.latitude = 34.076229;
    coTokushimaeki.longitude = 134.556612;
    //coを元にCustomAnnotation型の変数を生成
    CustomAnnotation *annotetion_tokushimaeki = [[CustomAnnotation alloc]initwithCoordinate:coTokushimaeki];
    annotetion_tokushimaeki.title = @"徳島城公園吟行地";
    annotetion_tokushimaeki.subtitle = [NSString stringWithFormat:@"%d句あります",number];
    
    //緯度と経度情報を格納
    coBizan.latitude = 34.061101;
    coBizan.longitude = 134.516636;
    //coを元にCustomAnnotation型の変数を生成
    CustomAnnotation *annotetion_bizan= [[CustomAnnotation alloc]initwithCoordinate:coBizan];
    annotetion_bizan.title = @"眉山吟行地";
    annotetion_bizan.subtitle = [NSString stringWithFormat:@"%d句あります",bizan_number];
    
    //緯度と経度情報を格納する変数の値を変更
    coTsurugisan.latitude = 34.044114;
    coTsurugisan.longitude = 134.543109;
    //coを元にannotetion型の2つめの変数を生成
    CustomAnnotation *annotetion_bunkanomori = [[CustomAnnotation alloc]initwithCoordinate:coTsurugisan];
    annotetion_bunkanomori.title = @"文化の森吟行地";
    annotetion_bunkanomori.subtitle = [NSString stringWithFormat:@"%d句あります",tsurugisan_number];
    
    //3つアノテーションを追加
    [self.map addAnnotation:annotetion_tokushimaeki];
    [self.map addAnnotation:annotetion_bizan];
    [self.map addAnnotation:annotetion_bunkanomori];
    
    //現在地を表示
    self.map.showsUserLocation = YES;
}

//オーバーレイ(地図上に描く円、ジオフェンスを描画する時に使う)を作成
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
{
    MKCircle* circle = overlay;
    MKCircleView* circleOverlayView =   [[MKCircleView alloc] initWithCircle:circle];
    circleOverlayView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    circleOverlayView.lineWidth = 4.;
    circleOverlayView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.35];
    return circleOverlayView;
}

//ジオフェンス設定（ジオフェンスを動作させるのに必要な準備）
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
    return YES;
}

//ジオフェンスが動作した後にこのメソッドが呼ばれる（起動した時にもともと領域内にいる場合はそのままだと知らせてくれないので、このメソッドによって判定してもらう）
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    //ログにジオフェンス設定されている箇所を確認のために書き出す
    NSLog(@"didStartMonitoringForRegion:%@", region.identifier);
    //現在の各ジオフェンスが領域外なのか領域内のかを調べるために- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{　が呼ばれる
    [self.locationManager requestStateForRegion:region];
}

//最初に地図を表示した時に領域内にいるのかいないのか
- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region{
    
    //領域内にいる
    switch (state) {
        case CLRegionStateInside:
            NSLog(@"%@は領域内です",region.identifier);
            [[[UIAlertView alloc] initWithTitle:(@"%@",region.identifier)
                                        message:@"吟行地への投稿と閲覧が可能です。"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil]show];
            //領域内の掲示板名を配列に格納
            [inRejon addObject:region.identifier];
            //確認のためinRejonの中身をログに書き出す
            for (int i = 0; i < inRejon.count; i++) {
                stringinrejon = [inRejon objectAtIndex:i];
                NSLog(@"inRejonの中身は%@",stringinrejon);
            }
            break;
            
            //領域外にいる
        case CLRegionStateOutside:
            NSLog(@"%@は領域外です",region.identifier);
            break;
            //認識できない
        case CLRegionStateUnknown:
            NSLog(@"%@見つからないです",region.identifier);
            break;
            //どれにも当てはまらない
        default:
            NSLog(@"%@見つからないです",region.identifier);
            break;
    }
    // 他のクラスからもinRejonを参照するためinRejonはグローバル変数に保存
    AppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    delegate.didRejon = inRejon;
}

//ジオフェンス監視（入ったとき呼ばれるメソッド）
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    
    NSLog(@"ジオフェンス領域%@に入りました",region.identifier);
    //[self.map addOverlay:circleTokushimaeki];
}

//ジオフェンス監視（出たとき呼ばれるメソッド）
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"ジオフェンス領域%@から出ました",region.identifier);
    //[self.map removeOverlay:circleTsurugisan];
}

//ホーム画面に戻るメソッド（これは他のviewcontrollerから呼ぶメソッド、消さないでください）
- (IBAction)goBackHome:(UIStoryboardSegue *)segue{
}

@end
