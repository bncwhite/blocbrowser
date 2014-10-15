//
//  BLCWebBrowserViewController.m
//  BlocBrowser
//
//  Created by Bradley White on 10/13/14.
//  Copyright (c) 2014 Bradley White. All rights reserved.
//

#import "BLCWebBrowserViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload command")

@interface BLCWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate, BLCAwesomeFloatingToolbarDelegate>

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) BLCAwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, assign) NSUInteger frameCount;
@property (nonatomic) UITapGestureRecognizer *tripleTouch;

@end

@implementation BLCWebBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    self.awesomeToolbar.frame = CGRectMake(20, 123, 335, 60);
}

#pragma mark - UIViewController

- (void)loadView
{
    UIView *mainView = [UIView new];
    
    self.webview = [UIWebView new];
    self.webview.delegate = self;
    
    self.textField = [UITextField new];
    self.textField.keyboardType = UIKeyboardTypeDefault;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textField.placeholder = NSLocalizedString(@"Website URL or Search", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220 / 255.0 alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[BLCAwesomeFloatingToolbar alloc] initWithFourTitles:@[kBLCWebBrowserBackString, kBLCWebBrowserForwardString, kBLCWebBrowserStopString, kBLCWebBrowserRefreshString]];
    
    self.awesomeToolbar.delegate = self;
    
    //Add a gesture to the webview so that if the toolbar is too small, a 3-finger touch will return it to its original size.
    self.tripleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnAwesomeToolbarToOriginalSize)];
    self.tripleTouch.numberOfTouchesRequired = 3;
    [self.webview addGestureRecognizer:self.tripleTouch];
    
    for (UIView *viewToAdd in @[self.webview, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}
- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    CGFloat originX = self.awesomeToolbar.frame.origin.x;
    CGFloat originY = self.awesomeToolbar.frame.origin.y;
    CGFloat frameWidth = self.awesomeToolbar.frame.size.width;
    CGFloat frameHeight = self.awesomeToolbar.frame.size.height;
    
    self.awesomeToolbar.frame = CGRectMake(originX, originY, frameWidth, frameHeight);
}

#pragma mark - BLCAwesomeFloatingToolbarDelegate

//- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title {
//    if ([title isEqual:kBLCWebBrowserBackString]) {
//        [self.webview goBack];
//    } else if ([title isEqual:kBLCWebBrowserForwardString]) {
//        [self.webview goForward];
//    } else if ([title isEqual:kBLCWebBrowserStopString]) {
//        [self.webview stopLoading];
//    } else if ([title isEqual:kBLCWebBrowserRefreshString]) {
//        [self.webview reload];
//    }
//}

- (void) floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didTryToResizeWithScale:(CGFloat)scale
{
    //Multiple the width and height by the scale
    CGRect potentialNewFrame = CGRectMake(toolbar.frame.origin.x, toolbar.frame.origin.y, toolbar.frame.size.width * scale, toolbar.frame.size.height * scale);
    
    CGSize minimumSize = CGSizeMake(83.75, 15);
    
    //Make sure the frame wont exceed self.view.bounds AND make sure it only gets so small. If it gets two small for user, a 3-finger touch will return it to its original size
    
    if (CGRectContainsRect(self.view.bounds, potentialNewFrame) && (potentialNewFrame.size.width > minimumSize.width || potentialNewFrame.size.height > minimumSize.height)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didRotateColorsInArray:(NSMutableArray *)colorsArray withArray:(NSMutableArray *)labelsArray
{
    UIColor *color = colorsArray.lastObject;
    
    [colorsArray insertObject:color atIndex:0];
    [colorsArray removeLastObject];
    
    for (UILabel *label in labelsArray) {
        NSUInteger currentIndex = [labelsArray indexOfObject:label];
        label.backgroundColor = colorsArray[currentIndex];
    }
    
}

- (void) returnAwesomeToolbarToOriginalSize
{
    //Returns it to original size after 3-finger touch
    self.awesomeToolbar.frame = CGRectMake(20, 123, 335, 60);
}

 #pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (!URL.scheme) {

        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if ([URLString containsString:@" "]) {
        
        NSString *googleQueryPrefix = @"http://www.google.com/search?q=";
        NSString *searchWords = URLString;
        NSString *query = [searchWords stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        NSString *googleSearch = [googleQueryPrefix stringByAppendingString:query];
        
        NSURL *googleSearchURL = [NSURL URLWithString:googleSearch];
        NSURLRequest *request = [NSURLRequest requestWithURL:googleSearchURL];
        [self.webview loadRequest:request];
            
    }else if (URL) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    
    return NO;
}

 #pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.frameCount++;
    [self updateButtonsAndTitle];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.frameCount--;
    [self updateButtonsAndTitle];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                    message:[error localizedDescription]
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    
    [self updateButtonsAndTitle];
    self.frameCount--;
}

#pragma mark - Miscellaneous

- (void) updateButtonsAndTitle {
    
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    
    [self.awesomeToolbar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
    [self.awesomeToolbar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
}

- (void) resetWebView {
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc] init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitle];
}

@end
