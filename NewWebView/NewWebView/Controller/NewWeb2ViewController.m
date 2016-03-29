//
//  NewWeb2ViewController.m
//  NewWebView
//
//  Created by kangda on 16/3/25.
//  Copyright © 2016年 kangda. All rights reserved.
//

#import "NewWeb2ViewController.h"
#import "UIViewController+BackButtonHandler.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@interface NewWeb2ViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, assign) BOOL Isallowedrun;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *mytimer;
@property (nonatomic, strong) UIBarButtonItem* closeBtn;
@end

@implementation NewWeb2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self makeNav];
    
    //初始化webview
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _webView=[[UIWebView alloc]initWithFrame:self.view.frame];
    _webView.delegate=self;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    [self.view addSubview:_webView];
    [_webView sizeToFit];
    [self addTapOnWebView];
    
    //创建进度条
    if(_progressView==nil)
    {
        _progressView=[[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame=CGRectMake(0, 64, self.view.frame.size.width, 1);
        [_progressView setTrackTintColor:[UIColor clearColor]];
        [_progressView setProgressTintColor:[UIColor grayColor]];
        [self.view addSubview:_progressView];
    }
    
    
}

/**
 *  定制化navigationBar
 */
-(void)makeNav
{
    switch (_navType) {
        case ZNNavType2Black:
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
    if(_isallowedPhotoZoom){
    CGPoint pt = [sender locationInView:_webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
    NSString *tagName = [_webView stringByEvaluatingJavaScriptFromString:js];
    NSLog(@"tag=%@",tagName);

    NSString *urlToSave = [_webView stringByEvaluatingJavaScriptFromString:imgURL];
    NSLog(@"image url=%@", urlToSave);
    
    if(urlToSave!=nil&&[tagName isEqualToString:@"IMG"])
    {
        [self showImageController:
         [NSString stringWithFormat:@"%@", urlToSave]];
    }
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

#pragma mark-webViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    _progressView.progress=0;
    _progressView.hidden=NO;
    _Isallowedrun=YES;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    //仿微信假进度条
    if(_mytimer==nil){
        _mytimer=[NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerrun) userInfo:nil repeats:YES];
    }
    
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"%d",navigationType);
    switch (navigationType) {
            
        case UIWebViewNavigationTypeLinkClicked:
        case UIWebViewNavigationTypeFormSubmitted:
        case UIWebViewNavigationTypeFormResubmitted:
            if (_isallowedLinkType) {
        
                    return YES;
            }else
            {
                return NO;
            }
            break;
       default:
            return YES;
            break;
    }
    
    return YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    _Isallowedrun=NO;
}

-(void)timerrun
{
    if(!_Isallowedrun){
        if(_progressView.progress>=1)
        {
            _progressView.hidden=YES;
            [_mytimer invalidate];
            _mytimer=nil;
        }
        else{
            _progressView.progress+=0.1;
        }
    }
    else{
        _progressView.progress+=0.05;
        if(_progressView.progress>=0.95)
        {
            _progressView.progress=0.95;
        }
    }
}


- (void)didReceiveMemoryWarning {
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
