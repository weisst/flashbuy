//
//  TDFontLibrary.h
//  UnionpayCard
//
//  Created by Dong Yiming on 2/20/14.
//  Copyright (c) 2014 Frodo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNfontLibrary : NSObject
AS_SINGLETON(FNfontLibrary)

@property (nonatomic, strong) UIFont    *fontTileButton;

@property (nonatomic, strong) UIFont    *fontLarge;
@property (nonatomic, strong) UIFont    *fontLargeBold;
@property (nonatomic, strong) UIFont    *fontNormal;
@property (nonatomic, strong) UIFont    *fontNormalBold;
@property (nonatomic, strong) UIFont    *fontSmall;

@property (nonatomic, strong) UIFont    *fontTitle;
@property (nonatomic, strong) UIFont    *fontTitleBold;
@end
