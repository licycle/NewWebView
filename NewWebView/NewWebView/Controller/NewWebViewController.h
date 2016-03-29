//
//  NewWebViewController.h
//  NewWebView
//
//  Created by kangda on 16/3/25.
//  Copyright © 2016年 kangda. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,ZNNavType) {
    ZNNavTypeBlack=0,
    ZNNavTypeBright
};

@interface NewWebViewController : UIViewController



@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL isallowedLinkType;
@property (nonatomic, assign) BOOL isallowedPhotoZoom;
@property (nonatomic, assign) ZNNavType navType;
@end
