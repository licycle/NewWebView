//
//  NewWebViewController.m
//  NewWebView
//
//  Created by kangda on 16/3/25.
//  Copyright © 2016年 kangda. All rights reserved.
//

#import "NewWebViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import <WebKit/WebKit.h>

@interface NewWebViewController () <WKUIDelegate, WKNavigationDelegate,
    UIGestureRecognizerDelegate>
@property (nonatomic, strong) WKWebView* webView;
@property (nonatomic, assign) NSInteger progressIndex;
@property (nonatomic, strong) UIProgressView* progressView;
@property (nonatomic, strong) UIBarButtonItem* closeBtn;
@end

@implementation NewWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeNav];

    //初始化webview
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _webView.navigationDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;

    [_webView
        loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    [self.view addSubview:_webView];
    [_webView sizeToFit];
    [self addTapOnWebView];

    //创建进度条
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc]
            initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 64, self.view.frame.size.width, 1);
        [_progressView setTrackTintColor:[UIColor clearColor]];
        [_progressView setProgressTintColor:[UIColor grayColor]];
        [self.view addSubview:_progressView];
        /*
     NSKeyValueObservingOptionNew 把更改之前的值提供给处理方法

     NSKeyValueObservingOptionOld 把更改之后的值提供给处理方法

     NSKeyValueObservingOptionInitial
     把初始化的值提供给处理方法，一旦注册，立马就会调用一次。通常它会带有新值，而不会带有旧值。

     NSKeyValueObservingOptionPrior 分2次调用。在值改变之前和值改变之后。

     */
        // 添加进度监控
        [_webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    }
}

// 自定义导航栏左侧按钮
// 将BarButtonItem添加到LeftBarButtonItem上
- (void)makeNav
{
    switch (_navType) {
    case ZNNavTypeBlack:
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        break;

    default:
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
        break;
    }

    _closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"关闭"
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(onclose)];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.navigationController.navigationBar.topItem.backBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:nil];
}

#pragma mark - BarButton Pressed

//  返回按钮触发的事件
- (void)onclose
{
    [self.navigationController popViewControllerAnimated:YES];
}

//捕获返回pop方法
- (BOOL)navigationShouldPopOnBackButton
{
    if (_webView.canGoBack) {
        [_webView goBack];
        self.navigationItem.leftBarButtonItem = _closeBtn;
        return NO;
    }
    else

    {
        return YES;
    }
}

//添加手势，识别点击事件
- (void)addTapOnWebView
{
    UITapGestureRecognizer* theTapRecognizer = [[UITapGestureRecognizer alloc]
        initWithTarget:self
                action:@selector(handleSingleTap:)];
    [_webView addGestureRecognizer:theTapRecognizer];
    theTapRecognizer.delegate = self;
    theTapRecognizer.cancelsTouchesInView = NO;
}

//允许手势点击
- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (nonnull UIGestureRecognizer*)otherGestureRecognizer
{
    return YES;
}

//点击放大图片事件
- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    CGPoint pt = [sender locationInView:_webView];
    NSString* imgURL = [NSString
        stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString* tag =
        [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName",
                  pt.x, pt.y];

    if (_isallowedPhotoZoom) {
        [_webView
            evaluateJavaScript:tag
             completionHandler:^(id _Nullable result, NSError* _Nullable error) {
           if (error == nil) {
             if (result != nil && [result isEqualToString:@"IMG"]) {
               [_webView
                   evaluateJavaScript:imgURL
                    completionHandler:^(id _Nullable result,
                                        NSError *_Nullable error) {
                      if (error == nil) {
                        if (result != nil && _isallowedPhotoZoom) {
                          NSLog(@"%@",
                                [NSString stringWithFormat:@"%@", result]);
                          [self showImageController:
                                    [NSString stringWithFormat:@"%@", result]];
                        }
                      } else {
                        NSLog(@"evaluateJavaScript error : %@",
                              error.localizedDescription);
                      }
                }];
             }
           }
             }];
    }
}

//第三方图片放大控件
- (void)showImageController:(NSString*)imgurl
{
    JTSImageInfo* imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.imageURL = [NSURL URLWithString:imgurl];

    // Setup view controller
    JTSImageViewController* imageViewer = [[JTSImageViewController alloc]
        initWithImageInfo:imageInfo
                     mode:JTSImageViewControllerMode_Image
          backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];

    // Present the view controller.
    [imageViewer
        showFromViewController:self
                    transition:
                        JTSImageViewControllerTransition_FromOriginalPosition];
}

//监控当前加载进度
- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString*, id>*)change
                       context:(void*)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == _webView) {
            if (_webView.estimatedProgress == 1.0) {
                _progressView.hidden = YES;
            }
            else {
                _progressView.progress = _webView.estimatedProgress;
            }
        }
    }
}

//退出时销毁监控
- (void)dealloc
{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

//收到转跳请求时响应
- (void)webView:(WKWebView*)webView
    didStartProvisionalNavigation:(WKNavigation*)navigation {
  _progressView.hidden = NO;
}

//检测是否允许链接点击
- (void)webView:(WKWebView*)webView
    decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:
                        (void (^)(WKNavigationActionPolicy))decisionHandler {
  //    NSLog(@"%@ %@",navigationAction.request.URL.relativeString,_url);
    NSLog(@"%d",[navigationAction navigationType]);
  switch ([navigationAction navigationType]) {
    case WKNavigationTypeLinkActivated:
    case WKNavigationTypeFormSubmitted:
    case WKNavigationTypeFormResubmitted:
      if (_isallowedLinkType) {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        else {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
        break;

    default:
        // Allow the webview to load this URL.
        decisionHandler(WKNavigationActionPolicyAllow);
        break;
    }

    if (_webView.canGoBack) {
        self.navigationItem.leftBarButtonItem = _closeBtn;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
