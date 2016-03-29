//
//  NewWeb2ViewController.h
//  NewWebView
//
//  Created by kangda on 16/3/25.
//  Copyright © 2016年 kangda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ZNNavType2) {
    ZNNavType2Black=0,
    ZNNavType2Bright
};

@interface NewWeb2ViewController : UIViewController



@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL isallowedLinkType;
@property (nonatomic, assign) BOOL isallowedPhotoZoom;
@property (nonatomic, assign) ZNNavType2 navType;
@end
