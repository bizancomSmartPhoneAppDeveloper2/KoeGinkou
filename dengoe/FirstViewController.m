//
//  FirstViewController.m
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/21.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import "FirstViewController.h"
#import "createPin.h"
#import <NCMB/NCMB.h>



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

@synthesize locationManager;

-(void)viewWillAppear:(BOOL)animated{
    }

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self locationManagerMethod];
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

    //[self didTouroku];
    //[self getObject];
    [self defaultMapSettei];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(MKAnnotationView*)mapView:(MKMapView*)_mapView viewForAnnotation:(id )annotation {
    // 現在地表示なら nil を返す
    if (annotation == self.map.userLocation) {
        return nil;
    }
    
    MKAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKAnnotationView*)[self.map dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    annotationView.image = [UIImage imageNamed:@"hitsuji.png"];
    annotationView.canShowCallout = YES;
    
    
    annotationView.annotation = annotation;
    
    return annotationView;
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
    [self didTouroku];

}

-(void)defaultMapSettei{
    //デリゲートを自分自身に設定
    self.map.delegate = self;
    //latitude = nowLocation.coordinate.latitude;
    //longitude = nowLocation.coordinate.longitude;
    NSLog(@"中心経度%f 中心緯度%f",latitude,longitude);
    //latitude = 34.074642;
    //longitude = 134.550764;
    //latitude = 35.710000;
    //longitude = 139.810000;
    //地図の真ん中の位置を緯度と経度で設定
    //co.latitude = 34.071369;
    //co.longitude = 134.556196;
    co.latitude = latitude;
    co.longitude = longitude;
    
    
    //地図の縮尺を設定、coを中心に1000m四方で設定
    self.map.region = MKCoordinateRegionMakeWithDistance(co, 1000, 1000);
    //区画内の建物表示プロパティ、初期値NO
    [self.map setShowsBuildings:YES];
    //コンビニなどランドマークの表示プロパティ、初期値NO
    [self.map setShowsPointsOfInterest:YES];
    //ユーザの現在地表示プロパティ（表示のされ方は純正マップアプリを参照）初期値NO
    [self.map setShowsUserLocation:YES];
    
}

-(void)createPin{
    // 徳島駅
    createPin *tokushimaEki = [[createPin alloc] init];
    tokushimaEki.coordinate = CLLocationCoordinate2DMake(34.074642, 134.550764);
    tokushimaEki.title = @"徳島駅の伝言板";
    
    //東京タワー
    createPin *tt = [[createPin alloc] init];
    tt.coordinate = CLLocationCoordinate2DMake(35.655333, 139.748611);
    tt.title = @"Tokyo Tower";
    
    // Tokyo Skytree
    createPin *st = [[createPin alloc] init];
    st.coordinate = CLLocationCoordinate2DMake(35.710139, 139.810833);
    st.title = @"Tokyo Skytree";
    
    [self.map addAnnotations:@[tokushimaEki,tt,st]];
    
    

}

-(void)didTouroku{
    //デリゲートします
    NSLog(@"デリゲートOK");
    //現在地を取得
    //現在地にピンを立てて
    createPin *genzaithi = [[createPin alloc] init];
    genzaithi.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    NSLog(@"%f,%fにピンを立てました",latitude,longitude);
    genzaithi.title = (@"１件の声登録があります");
    //hotpepper.subtitle = (@"%@",address);
    [self.map addAnnotations:@[genzaithi]];
    
    
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

-(void)QuerySearch{
    //検索開始地点に新宿駅の座標を設定
    double latitude1 = 35.690921;
    double longitude1 = 139.700258;
    NCMBGeoPoint *geoPoint = [NCMBGeoPoint geoPointWithLatitude:latitude1 longitude:longitude1];
    
    //設定した座標から5キロメートル内を検索
    NCMBQuery *geoQuery = [NCMBQuery queryWithClassName:@"Places"];
    [geoQuery whereKey:@"point" nearGeoPoint:geoPoint withinKilometers:5.0];
    [geoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if (!error) {
            //成功後の処理
            //NSLog(@"%@",geoQuery);
        }
        else{
            //エラー処理
            NSLog(@"error");
        }
    }];
    
}

-(void)getObject{
    NCMBQuery *query = [NCMBQuery queryWithClassName:@"Places"];
    [query whereKey:@"areaName" equalTo:@"新宿駅"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error) {
        for (NCMBObject *obj in objs) {
            //NSLog(@"%@", obj);
            
            // objectForKeyアクセス
            NSString *point = [obj objectForKey:@"point"];
            //NSLog(@"point:%@", point)
            NSString *areaName = [obj objectForKey:@"areaName"];
            // プロパティアクセス
            NSString *objectId = obj.objectId;
            //NSString *areaName = Places.areaName;
            NSLog(@"areaName:%@,objectId:%@,point:%@",areaName, objectId, point);
            // 再取得
            [obj refresh];
        }
    }];
}

-(void)createObjectAPI{
    NSString *areaName = @"新宿駅";
    
    //geoPointの生成
    double latitude0 = 35.690921;
    double longitude0 = 139.700258;
    NCMBGeoPoint *geoPoint = [NCMBGeoPoint geoPointWithLatitude:latitude0 longitude:longitude0];
    
    //geoPointの保存
    NCMBObject *obj = [NCMBObject objectWithClassName:@"Places"];
    [obj setObject:geoPoint forKey:@"point"];
    [obj setObject:areaName forKey:@"areaName"];
    [obj saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
        if (!error) {
            //成功後の処理
        }
        else {
            //エラー処理
        }
    }];
    
    NSString *areaName1 = @"高田馬場駅";
    
    //geoPointの生成
    NCMBGeoPoint *geoPoint1 = [NCMBGeoPoint geoPoint];
    geoPoint1.latitude = 35.712285;
    geoPoint1.longitude = 139.703782;
    
    //geoPointの保存
    NCMBObject *obj1 = [NCMBObject objectWithClassName:@"Places"];
    [obj1 setObject:geoPoint1 forKey:@"point"];
    [obj1 setObject:areaName1 forKey:@"areaName"];
    [obj1 saveInBackgroundWithBlock:^(BOOL succeeded , NSError *error){
        if (!error) {
            //成功後の処理
        }
        else {
            //エラー処理
        }
    }];
    
    //[self QuerySearch];

}
@end
