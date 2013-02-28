//
//  MBButtons.m
//  HudDemo
//
//  Created by pengfei huang on 13-2-21.
//  Copyright (c) 2013年 Matej Bukovinski. All rights reserved.
//

#import "QZAlertButtons.h"
#import <QuartzCore/QuartzCore.h>

@implementation QZAlertButtons

@synthesize padding;
@synthesize delegate    = _delegate;

#pragma mark - lifeCircle

- (id)initWithFrame:(CGRect)frame buttons:(NSArray*)btns {
    
    if(self = [self initWithFrame:frame]) {
        _buttons = [btns retain];
        self.padding = 8.0f;
        [self setupButtons];
    }
    return self;
}

- (void)dealloc
{
    [_btnsArray release];
    [_buttons release];
    [super dealloc];
}

#pragma mark - setupUi
- (void)resetAllSubViews
{
    for (int i = 0; i < _btnsArray.count; i++) {
        UIView* btn = [_btnsArray objectAtIndex:i];
        [btn removeFromSuperview];
    }
    [_btnsArray release];
    _btnsArray = nil;
}

- (void)setupButtons
{
    [self resetAllSubViews];
    
    _btnsArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (int i = 0; i < _buttons.count; i++) {
        NSString* text = (NSString*)[_buttons objectAtIndex:i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [btn setBackgroundImage:[[UIImage imageNamed:@"btn_alertdiaglog"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:@"btn_alertdiaglog_click"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0] forState:UIControlStateHighlighted];
        
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = i;
        
        [self addSubview:[btn autorelease]];
        [_btnsArray addObject:btn];
    }
}

- (void)layoutSubviews
{
    CGRect bounds = self.bounds;

    float paddingWidth = (_buttons.count - 1) * self.padding;
    CGFloat btnWidth = (bounds.size.width - paddingWidth) / _buttons.count;
    CGFloat btnHeight = bounds.size.height;
    
    for (int i = 0; i < _btnsArray.count; i++) {
        UIView* btn = [_btnsArray objectAtIndex:i];
        if(btn) {
            btn.frame = CGRectMake(i * (btnWidth + self.padding), 0, btnWidth, btnHeight);
        }
    }
}

#pragma mark - clickHandle
- (void)onButtonClick:(id)sender
{
    if([_delegate respondsToSelector:@selector(didClickAlertButton:)]) {
        [_delegate didClickAlertButton:sender];
    }
}

@end
