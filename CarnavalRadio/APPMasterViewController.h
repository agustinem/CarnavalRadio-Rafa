//
//  APPMasterViewController.h
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MarqueeLabel;

@interface APPMasterViewController : UIViewController <NSXMLParserDelegate, UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;

- (IBAction)buttonPlayMusic:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *barraBaja;
@property (weak, nonatomic) IBOutlet UIButton *botonPlay;
@end
