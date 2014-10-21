//
//  FirstViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "FirstViewController.h"
#import "createPin.h"



@interface FirstViewController ()

@end

@implementation FirstViewController{
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
    NSMutableArray *nameArray;
    NSMutableArray *addressArray;
    NSMutableArray *latArray;
    NSMutableArray *lngArray;
    NSMutableArray *namelabelArray;
    NSMutableArray *subviewArray;
    NSMutableArray *buttonArray;
    //緯度と経度情報を格納する変数の初期化(今回は鳴門市文化会館に設定)
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

}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self locationManagerMethod];
    [self defaultMapSettei];
    [self createPin];
    SecondViewController *rokuonView = self.parentViewController;
    rokuonView.delegate =self;
    
    
    
    //配列を空で生成
    nameArray  = [NSMutableArray array];
    addressArray = [NSMutableArray array];
    latArray = [NSMutableArray array];
    lngArray = [NSMutableArray array];
    namelabelArray = [NSMutableArray array];
    dbLat = 0;
    dbLng = 0;
    salonNumber = 0;

    [self didTouroku];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//現在地を取得
//現在地の緯度と経度を取得
// 位置情報が取得成功した場合にコールされる
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // 位置情報更新
    longitude = newLocation.coordinate.longitude;
    latitude = newLocation.coordinate.latitude;
    
    // 表示更新
    //NSLog(@"%f",longitude);
    //NSLog(@"%f",latitude);
}

// 位置情報が取得失敗した場合にコールされる。
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error) {
        NSString* message = nil;
        switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
            case kCLErrorDenied:
                // 位置情報取得停止
                [self.locationManager stopUpdatingLocation];
                message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
                break;
            default:
                message = [NSString stringWithFormat:@"位置情報の取得に失敗しました。"];
                break;
        }
        if (message) {
            // アラートを表示
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@""      message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
}


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    NSString *pin = @"pin";
    //pinで示すリサイクル可能なアノテーションビューかnilが返ってくる
    MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.map dequeueReusableAnnotationViewWithIdentifier:pin];
    if (pinView == nil) {
        //anotetionとpinを用いて値を代入
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pin];
        //表示する画像を設定
        //pinView.image = [UIImage imageNamed:@"hitsuji.png"];
        //ピンをクリックしたときに情報を表示するようにする
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
    }
    return pinView;
    
}

- (void)mapView:(MKMapView*)mapView didAddAnnotationViews:(NSArray*)views{
    // アノテーションビューを取得する
    salonNumber = 0;
    for (MKAnnotationView* annotationView in views) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // コールアウトの左側のアクセサリビューにボタンを追加する
        annotationView.leftCalloutAccessoryView = button;
        button.tag = salonNumber;
        salonNumber++;
        buttontag = button.tag;
        [buttonArray addObject:button];
        //NSLog(@"ボタン配列の要素が%ld個",buttonArray.count);
    }
}
//アノテーションのコールアウトに追加したボタンがタップされるとこのメソッドが呼ばれる
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //createPin型で生成(そうしないとopenやcloseなどが参照できないから)
    createPin *pin = view.annotation;
    // 表示view生成
    subview = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 400)];
    subview.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:subview];
    
    // 表示viewの、クローズボタンを生成
    UIButton *subviewClose = [[UIButton alloc] initWithFrame:CGRectMake(265, 10, 50, 25)];
    //subviewClose.backgroundColor = [UIColor blueColor];
    UIImage *img_close = [UIImage imageNamed:@"close_pink.gif"];  // ボタンにする画像を生成する
    [subviewClose setBackgroundImage:img_close forState:UIControlStateNormal];  // 画像をセットする
    [subviewClose addTarget:self action:@selector(subViewClose:) forControlEvents:UIControlEventTouchUpInside];
    [subview addSubview:subviewClose];
    
    [subview addSubview:namelabel];
    [subview addSubview:addresslabel];
    
    
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
    
    
    //デリゲートに保存したuserNameを取得する
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate]; // デリゲート呼び出し
    //userNameを表示
    NSLog(@"入力された文字は%@",appDelegate.userName_send);
    namelabel.text = [NSString stringWithFormat:@"%@\n%@",(appDelegate.userName_send),(appDelegate.date_send)];
    //addresslabel.text = (@"%@",view.annotation.subtitle);
    //NSLog(@"オープン時間:%@",pin.open);
    //NSLog(@"閉店時間%@",pin.close);
    
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
    // ロケーションマネージャーを作成
    BOOL locationServicesEnabled;
    self.locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]) {
        // iOS4.0以降はクラスメソッドを使用
        locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    } else {
        // iOS4.0以前はプロパティを使用
        locationServicesEnabled = self.locationManager.locationServicesEnabled;
    }
    
    if (locationServicesEnabled) {
        self.locationManager.delegate = self;
        
        // 位置情報取得開始
        [self.locationManager startUpdatingLocation];
    }
    
    
}

-(void)defaultMapSettei{
    //デリゲートを自分自身に設定
    self.map.delegate = self;
    
    latitude = 34.074642;
    longitude = 134.550764;
    //地図の真ん中の位置を緯度と経度で設定
    //co.latitude = 34.071369;
    //co.longitude = 134.556196;
    co.latitude = latitude;
    co.longitude = longitude;
    
    
    //地図の縮尺を設定、coを中心に1000m四方で設定
    self.map.region = MKCoordinateRegionMakeWithDistance(co, 2000, 2000);
    //区画内の建物表示プロパティ、初期値NO
    [self.map setShowsBuildings:YES];
    //コンビニなどランドマークの表示プロパティ、初期値NO
    [self.map setShowsPointsOfInterest:YES];
    //ユーザの現在地表示プロパティ（表示のされ方は純正マップアプリを参照）初期値NO
    //[self.map setShowsUserLocation:YES];
    
}

-(void)createPin{

    // 徳島駅
    createPin *tokushimaEki = [[createPin alloc] init];
    tokushimaEki.coordinate = CLLocationCoordinate2DMake(35.655333, 139.748611);
    tokushimaEki.title = @"徳島駅の伝言板";
    
    
    // Tokyo Skytree
    createPin *st = [[createPin alloc] init];
    st.coordinate = CLLocationCoordinate2DMake(35.710139, 139.810833);
    st.title = @"Tokyo Skytree";
    
    
    
    //mapにanotetionを追加
    //[self.map addAnnotation:pin];
    //[self.map addAnnotations:@[tt, st]];
    
}

-(void)didTouroku{
    //デリゲートします
    NSLog(@"デリゲートOK");
    //現在地を取得
    //現在地にピンを立てて
    createPin *genzaithi = [[createPin alloc] init];
    genzaithi.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    genzaithi.title = (@"１件の声登録があります");
    //hotpepper.subtitle = (@"%@",address);
    [self.map addAnnotations:@[genzaithi]];
    
    //デリゲートに保存したuserNameを取得する
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate]; // デリゲート呼び出し
    //userNameを表示
    NSLog(@"入力された文字は%@",appDelegate.userName_send);
    NSLog(@"%@",appDelegate.date_send);

    
    
    //ラベル追加
    namelabel = [[UILabel alloc] init];
    namelabel.frame = CGRectMake(20, 10, 200, 60);
    namelabel.numberOfLines = 2;
    namelabel.backgroundColor = [UIColor whiteColor];
    namelabel.textColor = [UIColor blackColor];
    namelabel.font = [UIFont fontWithName:@"AppleGothic" size:16];
    //NSLog(@"ラベルは%@",nameArray[i]);
    [namelabelArray addObject:namelabel];
    //NSLog(@"ラベル配列の要素は%ld個",namelabelArray.count);
    
    //ラベル追加
    //addresslabel = [[UILabel alloc] init];
    //addresslabel.frame = CGRectMake(10, 35, 260, 30);
    //addresslabel.backgroundColor = [UIColor whiteColor];
    //addresslabel.textColor = [UIColor blackColor];
    //addresslabel.font = [UIFont fontWithName:@"AppleGothic" size:13];
    

    //現在地ピンのアノケーションビューに録音再生ボタンと録音タイトルを表示
}
@end
