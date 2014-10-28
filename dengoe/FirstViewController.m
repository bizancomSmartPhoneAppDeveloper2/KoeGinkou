//
//  FirstViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "FirstViewController.h"
#import "CustomAnnotation.h"
//#import <NCMB/NCMB.h>
#import "WebViewController.h"

@interface FirstViewController ()
@end

@implementation FirstViewController{
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    CLLocationCoordinate2D co;
    double dbLat;
    double dbLng;
    NSString *nsstringlat;
    NSString *nsstringlng;
    NSDictionary *salondic;
    NSString *urlstr;
    NSURL *url;
    NSURLRequest *request;
    NSData *data;
    NSDictionary *dic;
    NSDictionary *resultdic;
    NSArray *salonarray;
    UIView *subview;
    UILabel *namelabel;
    UILabel *addresslabel;
    NSString *name;
    NSInteger salonNumber;
    NSInteger buttontag;
    AVAudioSession *audioSession;
    AVAudioPlayer *avPlayer;
    MKCircle *circle;
    NSString *defaultUserName;
    NSString *defaultUserDate;
    MKCoordinateRegion region;
}

@synthesize locationManager;

- (void)viewDidLoad {
    [self newAnnotation];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    latitude = 0;
    longitude = 0;
    [self.map setDelegate: self];
    [self locationManagerMethod];
    
    //配列を空で生成
    //nameArray  = [NSMutableArray array];
    
    // 500mの範囲円を追加
    circle = [MKCircle circleWithCenterCoordinate:co radius: 500.0];
    //[self getObject];
    //[self defaultMapSettei];
    CLLocationDistance radiusOnMeter = 100.0;
    
    CLRegion *grRegion = [[CLRegion alloc] initCircularRegionWithCenter:co radius:radiusOnMeter identifier:@"そごう"];
    [self.locationManager startMonitoringForRegion:grRegion];
    
    //ユーザが選択した都道府県があればそれをデフォルトとして表示する、保存されている都道府県を取り出してラベルに表示
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    defaultUserName = [defaults stringForKey:@"initialLetters"];

    
    //保存されているはずのユーザが選択した都道府県に対応する天気APIのURLを取り出す
    NSUserDefaults *defaults_1 = [NSUserDefaults standardUserDefaults];
    defaultUserDate = [defaults_1 stringForKey:@"initialLetters_1"];
    NSLog(@"%@",defaultUserDate);


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//アノテーションを追加してアノテーション(ピン)が表示されるときに呼ばれるメソッド
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //現在地の情報でないか
    if (annotation != self.map.userLocation) {
        NSString *pin = @"pin";
        //pinで示すリサイクル可能なアノテーションビューかnilが返ってくる
        MKAnnotationView *av = (MKAnnotationView*)[self.map dequeueReusableAnnotationViewWithIdentifier:pin];
        if (av == nil) {
            //anotetionとpinを用いて値を代入
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pin];
            //表示する画像を設定
            av.image = [UIImage imageNamed:@"hitsuji.png"];
            //ピンをクリックしたときに情報を表示するようにする
            av.canShowCallout = YES;
        }
        return av;
    }else{
        return nil;
    }
}

- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{
    // アノテーションビューを取得する
    salonNumber = 0;
    for (MKAnnotationView *annotationView in views) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // コールアウトの左側のアクセサリビューにボタンを追加する
        annotationView.leftCalloutAccessoryView = button;
        button.tag = salonNumber;
        salonNumber++;
        buttontag = button.tag;
        //NSLog(@"ボタン配列の要素が%ld個",buttonArray.count);
    }
    
}

//アノテーションのコールアウトに追加したボタンがタップされるとこのメソッドが呼ばれる
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //webViewに遷移
    WebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"webView"];
    [self presentViewController:webView animated:YES completion:nil];

    //アノテーションの情報を取得
    NSLog(@"title: %@", view.annotation.title);
    NSLog(@"subtitle: %@", view.annotation.subtitle);
    NSLog(@"coord: %f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude);
}

-(void)subViewClose:(UIButton*)stampPanelCloseBtn{
    // subviewを隠す
    subview.hidden = YES;
    [avPlayer stop];
}

-(void)subview_Listen:(UIButton*)stampPanelCloseBtn{
    //録音再生
    audioSession= [AVAudioSession sharedInstance];
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

-(void)locationManagerMethod{
    
    self.locationManager = [[CLLocationManager alloc] init];
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
        
        // 測位を開始する
        [self.locationManager startUpdatingLocation];
    }
}

//現在地を取得
//現在地の緯度と経度を取得
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

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [locations lastObject];
    NSLog(@"現在地経度%f 現在地緯度%f",
          location.coordinate.latitude,
          location.coordinate.longitude);
    latitude = location.coordinate.latitude;
    longitude = location.coordinate.longitude;
    [self.locationManager stopUpdatingLocation];
    [self defaultMapSettei];

}

-(void)defaultMapSettei{
    //デリゲートを自分自身に設定
    self.map.delegate = self;
    NSLog(@"中心経度%f 中心緯度%f",latitude,longitude);
    
    //地図の真ん中の位置を緯度と経度で設定
    co.latitude = latitude;
    co.longitude = longitude;
    //MKCooredinateRegionの変数の初期化
    region = self.map.region;
    //マップが表示された時の中心の経度設定
    region.center.longitude = co.longitude;
    //マップが表示された時の中心の緯度設定
    region.center.latitude = co.latitude;
    //現在地から店の距離によってマップの縮尺度を設定(幅1km分にする)
    //region.span.latitudeDelta = 1 / 111.2;
    //region.span.longitudeDelta = 1 / 111.2;
    //[self.map setRegion:region];
    
    
    //地図の縮尺を設定、coを中心に1000m四方で設定
    self.map.region = MKCoordinateRegionMakeWithDistance(co, 100000, 100000);
    //区画内の建物表示プロパティ、初期値NO
    [self.map setShowsBuildings:YES];
    //コンビニなどランドマークの表示プロパティ、初期値NO
    [self.map setShowsPointsOfInterest:YES];
    //ユーザの現在地表示プロパティ（表示のされ方は純正マップアプリを参照）初期値NO
    [self.map setShowsUserLocation:YES];
    
}


-(void)newAnnotation{
    //デリゲートを自分自身に設定
    self.map.delegate = self;
    
    
    NSInteger number;
    NSURL *suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/sub_listen_dengoe.php"];
    NSData *urldata = [NSData dataWithContentsOfURL:suburl];
    NSString *numstr = [[NSString alloc]initWithData:urldata encoding:NSUTF8StringEncoding];
    NSLog(@"徳島%@",numstr);
    number = [numstr intValue];
    
    NSInteger bizan_number;
    NSURL *bizan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/bizan_sub_listen_dengoe.php"];
    NSData *bizan_urldata = [NSData dataWithContentsOfURL:bizan_suburl];
    NSString *bizan_numstr = [[NSString alloc]initWithData:bizan_urldata encoding:NSUTF8StringEncoding];
    NSLog(@"眉山%@",bizan_numstr);
    bizan_number = [bizan_numstr intValue];
    
    NSInteger tsurugisan_number;
    NSURL *tsurugisan_suburl = [NSURL URLWithString:@"http://sayaka-sawada.main.jp/keijiban/tsurugisan_sub_listen_dengoe.php"];
    NSData *tsurugisan_urldata = [NSData dataWithContentsOfURL:tsurugisan_suburl];
    NSString *tsurugisan_numstr = [[NSString alloc]initWithData:tsurugisan_urldata encoding:NSUTF8StringEncoding];
    NSLog(@"剣山%@",tsurugisan_numstr);
    tsurugisan_number = [tsurugisan_numstr intValue];
    
    //緯度と経度情報を格納
    co.latitude = 34.061101;
    co.longitude = 134.516636;
    //coを元にsampleannotetion型の変数を生成
    CustomAnnotation *annotetion = [[CustomAnnotation alloc]initwithCoordinate:co];
    annotetion.title = @"眉山：掲示板";
    annotetion.subtitle = [NSString stringWithFormat:@"%d件の伝声があります",bizan_number];
    
    
    
        //緯度と経度情報を格納する変数の値を変更
        co.latitude = 34.074642;
        co.longitude = 134.550764;
        //coを元にannotetion型の2つめの変数を生成
        CustomAnnotation *annotetion2 = [[CustomAnnotation alloc]initwithCoordinate:co];
        annotetion2.title = @"徳島駅：掲示板";
        annotetion2.subtitle = [NSString stringWithFormat:@"%d件の伝声があります",number];
    
        //緯度と経度情報を格納する変数の値を変更
        co.latitude = 33.854063;
        co.longitude = 134.094674;
    //coを元にannotetion型の2つめの変数を生成
    CustomAnnotation *annotetion3 = [[CustomAnnotation alloc]initwithCoordinate:co];
    annotetion3.title = @"剣山：掲示板";
    annotetion3.subtitle = [NSString stringWithFormat:@"%d件の伝声があります",tsurugisan_number];
    
        //2つアノテーションを追加
        [self.map addAnnotation:annotetion];
        [self.map addAnnotation:annotetion2];
        [self.map addAnnotation:annotetion3];
    
        //現在地を表示
        self.map.showsUserLocation = YES;
}

//オーバーレイを作成
- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
{
    
    MKCircle* circle = overlay;
    MKCircleView* circleOverlayView =   [[MKCircleView alloc] initWithCircle:circle];
    circleOverlayView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    circleOverlayView.lineWidth = 4.;
    circleOverlayView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.35];
    return circleOverlayView;
    
}

//ジオフェンス設定
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager startUpdatingLocation];
    return YES;
}

//ジオフェンス監視（入ったとき呼ばれるメソッド）
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"ジオフェンス領域%@に入りました",region.identifier);
    [self.map addOverlay:circle];
}

//ジオフェンス監視（出たとき呼ばれるメソッド）
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"ジオフェンス領域%@から出ました",region.identifier);
    [self.map removeOverlay:circle];
    
}

-(void)createSubView{
    //CustomAnnotation型で生成(そうしないとopenやcloseなどが参照できないから)
    //CustomAnnotation *pin = view.annotation;
    // 表示view生成
    subview = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 400)];
    subview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:subview];
    //UIImage *denngonn_image = [UIImage imageNamed:@"denngonn.png"];
    //UIImageView *imageview = [[UIImageView alloc]initWithImage:denngonn_image];
    //[subview addSubview:imageview];
    
    // 表示viewの、クローズボタンを生成
    UIButton *subviewClose = [[UIButton alloc] initWithFrame:CGRectMake(265, 10, 50, 25)];
    //subviewClose.backgroundColor = [UIColor blueColor];
    UIImage *img_close = [UIImage imageNamed:@"close_pink.gif"];  // ボタンにする画像を生成する
    [subviewClose setBackgroundImage:img_close forState:UIControlStateNormal];  // 画像をセットする
    [subviewClose addTarget:self action:@selector(subViewClose:) forControlEvents:UIControlEventTouchUpInside];
    [subview addSubview:subviewClose];
    [subview addSubview:namelabel];
    [subview addSubview:addresslabel];
    
    //現在地ピンのアノケーションビューに録音再生ボタンと録音タイトルを生成
    UIButton *subview_ListenButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 20, 40, 40)];
    //subviewClose.backgroundColor = [UIColor blueColor];
    UIImage *img = [UIImage imageNamed:@"saisei.png"];  // ボタンにする画像を生成する
    [subview_ListenButton setBackgroundImage:img forState:UIControlStateNormal];  // 画像をセットする
    [subview_ListenButton addTarget:self action:@selector(subview_Listen:) forControlEvents:UIControlEventTouchUpInside];
    [subview addSubview:subview_ListenButton];
    
    [subview addSubview:namelabel];
    //[subview addSubview:addresslabel];
    
    // annotationView.annotation でどのアノテーションか判定可能
    //NSLog(@"annotationView annotation is %@", view.annotation);
    // アノテーションバルーンのcoordinate(リバースジオコーディングするときの情報)
    //NSLog(@"annotationView coordinate is %f", view.annotation.coordinate.latitude); NSLog(@"annotationView coordinate is %f", view.annotation.coordinate.longitude);
    //NSLog(@"annotationView title is %@", view.annotation.title); // アノテーションバルーンのtitle
    //NSLog(@" annotationView subtitle is %@", view.annotation.subtitle); // アノテーションバルーンのsubtitle
    
    //ラベル追加
    namelabel = [[UILabel alloc] init];
    namelabel.frame = CGRectMake(20, 10, 200, 60);
    namelabel.numberOfLines = 2;
    namelabel.backgroundColor = [UIColor whiteColor];
    namelabel.textColor = [UIColor blackColor];
    namelabel.font = [UIFont fontWithName:@"AppleGothic" size:16];
    //NSLog(@"ラベルは%@",nameArray[i]);
    
    //NSLog(@"ラベル配列の要素は%ld個",namelabelArray.count);
    
    //ラベル追加
    //addresslabel = [[UILabel alloc] init];
    //addresslabel.frame = CGRectMake(10, 35, 260, 30);
    //addresslabel.backgroundColor = [UIColor whiteColor];
    //addresslabel.textColor = [UIColor blackColor];
    //addresslabel.font = [UIFont fontWithName:@"AppleGothic" size:13];
    
    //デリゲートに保存したuserNameを取得する
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate]; // デリゲート呼び出し
    //userNameを表示
    NSLog(@"入力された文字は%@");
    namelabel.text = [NSString stringWithFormat:@"%@\n%@"];
    
    //ユーザが選択した都道府県のデータの保存
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:defaultUserName forKey:@"initialLetters"];
    
    //ユーザが選択した都道府県に対応するのURLの保存
    NSUserDefaults *defaults_1 = [NSUserDefaults standardUserDefaults];
    [defaults_1 setObject:defaultUserDate forKey:@"initialLetters_1"];
    //addresslabel.text = (@"%@",view.annotation.subtitle);
    //NSLog(@"オープン時間:%@",pin.open);
    //NSLog(@"閉店時間%@",pin.close);
}

- (IBAction)goBackHome:(UIStoryboardSegue *)segue{
}

@end
