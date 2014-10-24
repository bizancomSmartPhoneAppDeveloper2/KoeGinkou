//
//  tableTableViewController.h
//  dengoe
//
//  Created by ビザンコムマック０４ on 2014/10/24.
//  Copyright (c) 2014年 ビザンコムマック０４. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tableTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *dataSourceiPhone;
@end
