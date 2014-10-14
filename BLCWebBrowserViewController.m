//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Bradley White on 10/13/14.
//  Copyright (c) 2014 Bradley White. All rights reserved.
//

#import "BLCWebBrowserViewController.h"

@interface BLCWebBrowserViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webview;

@end

@implementation BLCWebBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)loadView {
    UIView *mainView = [UIView new];
    
    self.webview = [UIWebView new];
    self.webview.delegate = self;
    
    NSString *urlString = @"http://wikipedia.org";
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
    
    [mainView addSubview:self.webview];
    self.view = mainView;
}
- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.webview.frame = self.view.frame;
}

@end
