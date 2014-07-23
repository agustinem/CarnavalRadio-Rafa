//
//  APPDetailViewController.h
//  RSSreader
//
//  Created by Rafael Garcia Leiva on 08/04/13.
//  Copyright (c) 2013 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NJKWebViewProgress.h>

@interface APPDetailViewController : UIViewController <NJKWebViewProgressDelegate, UIWebViewDelegate>

@property (copy, nonatomic) NSString *url;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)reloadButton:(id)sender;

@end
