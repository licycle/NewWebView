//
//  ViewController.m
//  NewWebView
//
//  Created by kangda on 16/3/24.
//  Copyright © 2016年 kangda. All rights reserved.
//

#import "ViewController.h"
#import "NewWebViewController.h"
#import "NewWeb2ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor orangeColor]];
    UIButton *click=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    click.center=self.view.center;
    [click setTitle:@"click" forState:UIControlStateNormal];
    [self.view addSubview:click];
    [click addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchDown];
    
    UIButton *click2=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    click2.center=CGPointMake(self.view.center.x, self.view.center.y+100);
    [click2 setTitle:@"click" forState:UIControlStateNormal];
    [self.view addSubview:click2];
    [click2 addTarget:self action:@selector(click2) forControlEvents:UIControlEventTouchDown];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)click{
    NewWebViewController *v=[[NewWebViewController alloc]init];
    v.url=@"http://baidu.com";
    v.isallowedPhotoZoom=YES;
    v.isallowedLinkType=YES;
    v.navType=ZNNavTypeBlack;
    [self.navigationController pushViewController:v animated:YES];
}


-(void)click2{
    NewWeb2ViewController *v=[[NewWeb2ViewController alloc]init];
    v.url=@"http://baidu.com";
    v.isallowedPhotoZoom=YES;
    v.isallowedLinkType=YES;
    v.navType=ZNNavType2Black;
    [self.navigationController pushViewController:v animated:YES];
}

-(void)test{
    self.title=@"test";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
