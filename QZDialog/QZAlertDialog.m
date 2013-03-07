//
//  QZDialog.m
//  HudDemo
//
//  Created by pengfei huang on 13-2-25.
//  Copyright (c) 2013年 flyhuang. All rights reserved.
//

#import "QZAlertDialog.h"
#import "QZBaseDialog_protected.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kConfirmTitleLableFontSize = 20.f;
static const CGFloat kConfirmContentLabelFontSize = 16.f;

static const CGFloat kTipTitleLableFontSize = 18.f;
static const CGFloat kTipContentLabelFontSize = 14.f;

static const CGFloat kFixInnerWidth = 260.0f;
static const CGFloat kFixOuterWidth = 296.0f;
static const CGFloat kButtonsHeight = 48.0f;
static const CGFloat kInputKeyboardMargin = 15.0f;

static const CGFloat kTipWidth  = 80.0f;
static const CGFloat kTipHeight = 80.0;

#define kAlertTitleFontName   @"HelveticaNeue-Bold"
#define kAlertContentFontName @"HelveticaNeue"

#define kConfirmBgImage       @"bg_alertdialog"
#define kTipBgImage           @"bg_alertdialog_success"

@implementation QZAlertDialog

@synthesize title;
@synthesize content;
@synthesize titleFont;
@synthesize contentFont;
@synthesize alertMode = _alertMode;
@synthesize confirmBtnText;
@synthesize cancelBtnText;
@synthesize alertDelegate = _alertDelegate;
@synthesize autoCloseAfterClick;
@synthesize tipImage;
@synthesize inputText = _inputText;
@synthesize dlgBackGroundImage = _dlgBackGroundImage;

#if NS_BLOCKS_AVAILABLE
@synthesize confirmBlock, cancelBlock;
#endif

#pragma mark - class methods
+ (QZAlertDialog*)showConfirmDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated
                          alertDelegate:(id<QZAlertDialogDelegate>)delegate
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertConfirm;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.alertDelegate = delegate;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showCancelDlgAddedTo:(UIView *)view
                                 title:(NSString*)title
                               content:(NSString*)content
                              animated:(BOOL)animated
                         alertDelegate:(id<QZAlertDialogDelegate>)delegate
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertCancel;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.alertDelegate = delegate;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showInputDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                        alertDelegate:(id<QZAlertDialogDelegate>)delegate
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertInput;
    dialog.alertDelegate = delegate;
    dialog.removeFromSuperViewOnHide = YES;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showProgressDlgAddedTo:(UIView *)view
                                   title:(NSString*)title
                                 content:(NSString*)content
                                animated:(BOOL)animated
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertProgress;
    dialog.removeFromSuperViewOnHide = YES;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showProgressHasButtonDlgAddedTo:(UIView *)view
                                            title:(NSString*)title
                                          content:(NSString*)content
                                         animated:(BOOL)animated
                                    alertDelegate:(id<QZAlertDialogDelegate>)delegate
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertProgressWithButton;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.alertDelegate = delegate;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showTipDlgAddedTo:(UIView *)view
                              title:(NSString*)title
                            content:(NSString*)content
                           animated:(BOOL)animated
                     hideAfterDelay:(float)delay
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertTip;
    dialog.removeFromSuperViewOnHide = YES;
    [dialog show:animated hideAfterDelay:delay];
    return [dialog autorelease];
}

+ (NSArray *)allDlgsForView:(UIView *)view
{
    NSMutableArray *huds = [NSMutableArray array];
	NSArray *subviews = view.subviews;
	Class hudClass = [QZAlertDialog class];
	for (UIView *aView in subviews) {
		if ([aView isKindOfClass:hudClass]) {
			[huds addObject:aView];
		}
	}
	return [NSArray arrayWithArray:huds];
}

+ (NSUInteger)hideAllDlgsForView:(UIView *)view animated:(BOOL)animated
{
    NSArray *huds = [self allDlgsForView:view];
	for (QZAlertDialog *hud in huds) {
		[hud hide:animated];
	}
	return [huds count];
}

+ (BOOL)hideDlgForView:(UIView *)view animated:(BOOL)animated
{
    QZAlertDialog *hud = [QZAlertDialog dlgForView:view];
	if (hud != nil) {
		[hud hide:animated];
		return YES;
	}
	return NO;
}

+ (QZAlertDialog *)dlgForView:(UIView *)view
{
	Class hudClass = [QZAlertDialog class];
	NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
	for (UIView *subview in subviewsEnum) {
		if ([subview isKindOfClass:hudClass]) {
			return (QZAlertDialog *)subview;
		}
	}
	return nil;
}

#if NS_BLOCKS_AVAILABLE
+ (QZAlertDialog*)showConfirmDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated
                                confirm:(QZDialogClickEventBlock)confirmClick
                                 cancel:(QZDialogClickEventBlock)cancelClick
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertConfirm;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.confirmBlock = confirmClick;
    dialog.cancelBlock = cancelClick;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showCancelDlgAddedTo:(UIView *)view
                                 title:(NSString*)title
                               content:(NSString*)content
                              animated:(BOOL)animated
                                cancel:(QZDialogClickEventBlock)cancelClick
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertCancel;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.cancelBlock = cancelClick;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showInputDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                              confirm:(QZDialogClickEventBlock)confirmClick
                               cancel:(QZDialogClickEventBlock)cancelClick
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertInput;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.cancelBlock = cancelClick;
    dialog.confirmBlock = confirmClick;
    [dialog show:animated];
    return [dialog autorelease];
}

+ (QZAlertDialog*)showProgressHasButtonDlgAddedTo:(UIView *)view
                                            title:(NSString*)title
                                          content:(NSString*)content
                                         animated:(BOOL)animated
                                           cancel:(QZDialogClickEventBlock)cancelClick
{
    QZAlertDialog* dialog = [[QZAlertDialog alloc] initWithView:view];
    [view addSubview:dialog];
    dialog.title = title;
    dialog.content = content;
    dialog.alertMode = QZAlertProgressWithButton;
    dialog.removeFromSuperViewOnHide = YES;
    dialog.cancelBlock = cancelClick;
    [dialog show:animated];
    return [dialog autorelease];
}

#endif

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        self.fixWidth = 0;
        self.confirmBtnText = @"确定";
        self.cancelBtnText  = @"取消";
        self.alertMode = QZAlertConfirm;
        self.maskOpacity = 0.4f;
        self.margin = 15.0f;
        //由于上下都有阴影，所以设置的边距要加上阴影的大小，15 + 5
        self.paddingTop = 25.0;
        self.paddingBottom = 25.0;
        self.paddingLeft = 15.0;
        self.paddingRight = 15.0;
        self.autoCloseAfterClick = YES;
        
        self.paddingTopCenter = 15.0;
        self.paddingCenterBottom = 15.0;
        
#if NS_BLOCKS_AVAILABLE
        self.confirmBlock = nil;
        self.cancelBlock = nil;
#endif
        
        self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:kConfirmTitleLableFontSize];
		self.contentFont = [UIFont fontWithName:@"HelveticaNeue" size:kConfirmContentLabelFontSize];
        self.tipImage = [UIImage imageNamed:@"icon_success"];
        _inputText = @"";
        self.backgroundColor = [UIColor clearColor];
        self.dlgBackGroundImage = [[UIImage imageNamed:kConfirmBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        [self setupAll];
    }
	return self;
}

- (void)dealloc
{
    self.title = nil;
    self.content = nil;
    self.titleFont = nil;
    self.contentFont = nil;
    self.confirmBtnText = nil;
    self.cancelBtnText = nil;
    self.tipImage = nil;
    self.dlgBackGroundImage = nil;
    self.alertDelegate = nil;
#if NS_BLOCKS_AVAILABLE
    self.confirmBlock = nil;
    self.cancelBlock = nil;
#endif
    
    [super dealloc];
}

- (void)setupAll
{
    self.topView = nil;
    self.bottomView = nil;
    self.centerView = nil;
    _inputText = @"";
    _inputTextField = nil;
    
    switch (self.alertMode) {
        case QZAlertConfirm: {
            self.maskType = QZDialogMaskOpacity;
            self.fixWidth = kFixOuterWidth;
            self.square = NO;
            self.minSize = CGSizeZero;
            self.paddingTopCenter = 10.0;
            self.paddingCenterBottom = 15.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kConfirmTitleLableFontSize];
            self.paddingTop = 19.0;
            self.paddingBottom = 19.0;
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kConfirmContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kConfirmBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertCancel: {
            self.maskType = QZDialogMaskOpacity;
            self.fixWidth = kFixOuterWidth;
            self.square = NO;
            self.minSize = CGSizeZero;
            self.paddingTopCenter = 10.0;
            self.paddingCenterBottom = 15.0;
            self.paddingTop = 19.0;
            self.paddingBottom = 19.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kConfirmTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kConfirmContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kConfirmBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertInput:{
            self.maskType = QZDialogMaskOpacity;
            self.fixWidth = kFixOuterWidth;
            self.square = NO;
            self.minSize = CGSizeZero;
            self.paddingTopCenter = 15.0;
            self.paddingCenterBottom = 15.0;
            self.paddingTop = 19.0;
            self.paddingBottom = 19.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kConfirmTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kConfirmContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kConfirmBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertProgressWithButton: {
            self.maskType = QZDialogMaskOpacity;
            self.fixWidth = kFixOuterWidth;
            self.square = NO;
            self.minSize = CGSizeZero;
            self.paddingTopCenter = 25.0;
            self.paddingCenterBottom = 25.0;
            self.paddingTop = 19.0;
            self.paddingBottom = 19.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kConfirmTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kConfirmContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kConfirmBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertProgress:{
            self.maskType = QZDialogMaskNone;
            self.fixWidth = 175;
            self.square = YES;
            self.minSize = CGSizeMake(175, 175);
            self.paddingTopCenter = 5.0;
            self.paddingCenterBottom = 7.0;
            self.paddingTop = 25.0;
            self.paddingBottom = 25.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kTipTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kTipContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kTipBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertTip: {
            self.maskType = QZDialogMaskNone;
            self.fixWidth = 175;
            self.square = YES;
            self.minSize = CGSizeMake(175, 175);
            self.paddingTopCenter = 13.0;
            self.paddingCenterBottom = 7.0;
            self.paddingTop = 25.0;
            self.paddingBottom = 25.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kTipTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kTipContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kTipBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
        case QZAlertTipCustomInCenter: {
            self.maskType = QZDialogMaskNone;
            self.fixWidth = 0;
            self.square = NO;
            self.minSize = CGSizeMake(100, 100);
            self.paddingTopCenter = 13.0;
            self.paddingCenterBottom = 7.0;
            self.paddingTop = 25.0;
            self.paddingBottom = 25.0;
            self.titleFont = [UIFont fontWithName:kAlertTitleFontName size:kTipTitleLableFontSize];
            self.contentFont = [UIFont fontWithName:kAlertContentFontName size:kTipContentLabelFontSize];
            self.dlgBackGroundImage = [[UIImage imageNamed:kTipBgImage] stretchableImageWithLeftCapWidth:20.0 topCapHeight:20.0];
        } break;
    }
    
    [self setupTopView];
    [self setupCenterView];
    [self setupBottomView];
}

- (void)setupTopView
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel:
        case QZAlertInput:
        case QZAlertProgress:
        case QZAlertProgressWithButton:
        case QZAlertTip:
        case QZAlertTipCustomInCenter: {
            UILabel* label = [[UILabel alloc] initWithFrame:self.bounds];
            label.adjustsFontSizeToFitWidth = NO;
            label.textAlignment = QZDialogLabelAlignmentCenter;
            label.opaque = NO;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];
            label.font = self.titleFont;
            label.text = self.title;
            self.topView = [label autorelease];
        }
            break;
    }
}

- (void)setupCenterView
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel: {
            UILabel* detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
            detailsLabel.font = self.contentFont;
            detailsLabel.adjustsFontSizeToFitWidth = NO;
            detailsLabel.textAlignment = QZDialogLabelAlignmentCenter;
            detailsLabel.opaque = NO;
            detailsLabel.backgroundColor = [UIColor clearColor];
            detailsLabel.textColor = [UIColor whiteColor];
            detailsLabel.numberOfLines = 0;
            detailsLabel.text = self.content;
            self.centerView = [detailsLabel autorelease];
        }; break;
        case QZAlertInput:{
            
            float padding = 5.0f;
            float kInputHeight = 34.0f;
            
            UIView* wrapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFixInnerWidth, kInputHeight)];
            
            UIImageView* boarderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kFixInnerWidth, kInputHeight)];
            boarderView.image = [[UIImage imageNamed:@"inputbox_remark"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:5.0];
            
            UITextField* feild = [[UITextField alloc] initWithFrame:CGRectMake(padding, padding + 2, kFixInnerWidth - 2 * padding , kInputHeight - 2 *padding)];
            feild.delegate = self;
            feild.placeholder = @"";
            feild.textColor = [UIColor whiteColor];
            feild.font = [UIFont systemFontOfSize:16.0f];
            feild.returnKeyType = UIReturnKeyDone;
            
            //保存在成员变量里
            _inputTextField = feild;
            
            [wrapView addSubview:[boarderView autorelease]];
            [wrapView addSubview:[feild autorelease]];
            
            self.centerView = [wrapView autorelease];
            
        }; break;
        case QZAlertProgressWithButton:{
            UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [indicator startAnimating];
            self.centerView = [indicator autorelease];
        }; break;
        case QZAlertProgress: {
            UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, kTipWidth, kTipHeight)];
            indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [indicator startAnimating];
            self.centerView = [indicator autorelease];
        }; break;
        case QZAlertTip: {
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kTipWidth, kTipHeight)];
            imageView.image = self.tipImage;
            self.centerView = [imageView autorelease];
        }; break;
        case QZAlertTipCustomInCenter: {
        } break;
        default:
            break;
    }
}

- (void)setupBottomView
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel:
        case QZAlertInput:
        case QZAlertProgressWithButton: {
            NSArray* buttonsArr = nil;
            if(self.alertMode == QZAlertConfirm || self.alertMode == QZAlertInput) {
                buttonsArr = [NSArray arrayWithObjects:self.cancelBtnText,self.confirmBtnText,nil];
            } else {
                buttonsArr = [NSArray arrayWithObjects:self.cancelBtnText,nil];
            }
            
            QZAlertButtons* buttons = [[QZAlertButtons alloc] initWithFrame:CGRectMake(0, 0, kFixInnerWidth, kButtonsHeight) buttons:buttonsArr];
            buttons.delegate = self;
            self.bottomView = [buttons autorelease];
        } break;
        case QZAlertProgress:
        case QZAlertTip:
        case QZAlertTipCustomInCenter : {
            UILabel* detailsLabel = [[UILabel alloc] initWithFrame:self.bounds];
            detailsLabel.font = self.contentFont;
            detailsLabel.adjustsFontSizeToFitWidth = NO;
            detailsLabel.textAlignment = QZDialogLabelAlignmentCenter;
            detailsLabel.opaque = NO;
            detailsLabel.backgroundColor = [UIColor clearColor];
            detailsLabel.textColor = [UIColor whiteColor];
            detailsLabel.numberOfLines = 0;
            detailsLabel.text = self.content;
            self.bottomView = [detailsLabel autorelease];
        }
            break;
    }
}

#pragma mark - notification
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtkeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(txtkeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [super registerForNotifications];
}

#pragma mark - should ovverride
- (CGSize)topSize:(CGSize)maxSize
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel:
        case QZAlertInput:
        case QZAlertProgress:
        case QZAlertProgressWithButton:
        case QZAlertTip:
        case QZAlertTipCustomInCenter: {
            if([self.topView isKindOfClass:[UILabel class]]) {
                UILabel* labelTitle = (UILabel*)self.topView;
                CGSize labelSize = [self.title sizeWithFont:labelTitle.font];
                labelSize.width = MIN(labelSize.width, maxSize.width);
                return labelSize;
            }
        }
    }
    
    if(self.topView) {
        return self.topView.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)centerSize:(CGSize)maxSize
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel: {
            if([self.centerView isKindOfClass:[UILabel class]]) {
                UILabel* contentLabel = (UILabel*)self.centerView;
                CGSize detailsLabelSize = [self.content sizeWithFont:contentLabel.font
                                                   constrainedToSize:maxSize lineBreakMode:contentLabel.lineBreakMode];
                return detailsLabelSize;
            } 
        } break;
        case QZAlertInput:
        case QZAlertProgress:
        case QZAlertProgressWithButton:
        case QZAlertTip:
        case QZAlertTipCustomInCenter: {
        } break;
    }
    
    if(self.centerView) {
        return self.centerView.bounds.size;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)bottomSize:(CGSize)maxSize
{
    switch (self.alertMode) {
        case QZAlertConfirm:
        case QZAlertCancel:
        case QZAlertInput:
        case QZAlertProgressWithButton:{
        } break;
        case QZAlertProgress:
        case QZAlertTip:{
            //tip模式不支持多行文本
            if([self.bottomView isKindOfClass:[UILabel class]]) {
                UILabel* contentLabel = (UILabel*)self.bottomView;
                CGSize labelSize = [self.content sizeWithFont:contentLabel.font];
                labelSize.width = MIN(labelSize.width, maxSize.width);
                return labelSize;
            }
        } break;
        case QZAlertTipCustomInCenter: {
            if([self.bottomView isKindOfClass:[UILabel class]]) {
                UILabel* contentLabel = (UILabel*)self.bottomView;
                CGSize detailsLabelSize = [self.content sizeWithFont:contentLabel.font
                                                   constrainedToSize:maxSize lineBreakMode:contentLabel.lineBreakMode];
                return detailsLabelSize;
            }
        } break;
    }
    
    if(self.bottomView) {
        return self.bottomView.bounds.size;
    } else {
        return CGSizeZero;
    }
}

#pragma mark - public method
- (NSString*)getInputText
{
    return self.inputText;
}

#pragma mark - customBg
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(_inputTextField) {
        [_inputTextField becomeFirstResponder];
    }
}

- (void)drawRect:(CGRect)rect
{
    //如果用户没有指定背景图片则用原生父类的背景
    if(self.dlgBackGroundImage) {
        if(self.maskType == QZDialogMaskOpacity) {
            [self drawOpacityMaskBackView];
        } else if(self.maskType == QZDialogMaskGradient){
            [self drawGardiantBackView];
        }
        
        CGRect allRect = self.bounds;
        
        CGRect boxRect = CGRectMake(roundf((allRect.size.width - self.size.width) / 2) + self.xOffset,
                                    roundf((allRect.size.height - self.size.height) / 2) + self.yOffset, self.size.width, self.size.height);
        
        [self.dlgBackGroundImage drawInRect:boxRect];
    } else {
        [super drawRect:rect];
    }
}

#pragma mark - KVO
- (NSArray *)observableKeypaths {
    NSMutableArray* array = [NSMutableArray arrayWithArray:[super observableKeypaths]];
    NSMutableArray* newArrats = [NSArray arrayWithObjects:@"title", @"titleFont", @"content", @"contentFont", @"confirmBtnText", @"cancelBtnText", @"alertMode" ,@"tipImage", @"dlgBackGroundImage",nil];
    [array addObjectsFromArray:newArrats];
    return newArrats;
}

- (BOOL)updateUIForKeypath:(NSString *)keyPath
{
    BOOL needsRepaint = YES;
    
    if ([keyPath isEqualToString:@"title"]) {
        if([self.topView isKindOfClass:[UILabel class]]) {
            UILabel* labelTitle = (UILabel*)self.topView;
            labelTitle.text = self.title;
            if(self.title == nil || self.title.length == 0) {
                self.topView = nil;
            }
        }
	} else if ([keyPath isEqualToString:@"titleFont"]) {
        if([self.topView isKindOfClass:[UILabel class]]) {
            UILabel* labelTitle = (UILabel*)self.topView;
            labelTitle.font = self.titleFont;
        }
	} else if ([keyPath isEqualToString:@"content"]) {
        
        switch (self.alertMode) {
            case QZAlertConfirm:
            case QZAlertCancel: {
                if([self.centerView isKindOfClass:[UILabel class]]) {
                    UILabel* labelContent = (UILabel*)self.centerView;
                    labelContent.text = self.content;
                    
                    if(self.content == nil || self.content.length == 0) {
                        self.centerView = nil;
                    }
                }
            } break;
            case QZAlertInput:
            case QZAlertProgressWithButton:
            case QZAlertProgress: {
                
            } break;
            case QZAlertTip:
            case QZAlertTipCustomInCenter: {
                if([self.bottomView isKindOfClass:[UILabel class]]) {
                    UILabel* labelContent = (UILabel*)self.bottomView;
                    labelContent.text = self.content;
                    if(self.content == nil || self.content.length == 0) {
                        self.bottomView = nil;
                    }
                }
            } break;
        }
        
    } else if ([keyPath isEqualToString:@"contentFont"]) {
        if([self.centerView isKindOfClass:[UILabel class]]) {
            UILabel* labelContent = (UILabel*)self.centerView;
            labelContent.font = self.contentFont;
        }
    } else if ([keyPath isEqualToString:@"confirmBtnText"]) {
        self.bottomView = nil;
        [self setupBottomView];
    } else if ([keyPath isEqualToString:@"cancelBtnText"]) {
        self.bottomView = nil;
        [self setupBottomView];
    } else if ([keyPath isEqualToString:@"alertMode"]) {
        [self setupAll];
    }
    
    return needsRepaint || [super updateUIForKeypath:keyPath];
}

#pragma mark - QZAlertButtonsDelegate

- (void)didClickAlertButton:(id)sender
{
    if(_inputTextField) {
        _inputText = _inputTextField.text;
    }
    
    if([sender isKindOfClass:[UIButton class]]) {
        if(self.alertMode == QZAlertCancel) {
            if([_alertDelegate respondsToSelector:@selector(onClickAlertDlgCancelButton:dialog:)]) {
                [_alertDelegate onClickAlertDlgCancelButton:sender dialog:self];
            }
            
#if NS_BLOCKS_AVAILABLE
            if(self.cancelBlock) {
                self.cancelBlock(self);
            }
#endif
        } else {
            UIView* view = (UIView*)sender;
            if(view.tag == 0) {
                if([_alertDelegate respondsToSelector:@selector(onClickAlertDlgCancelButton:dialog:)]) {
                    [_alertDelegate onClickAlertDlgCancelButton:sender dialog:self];
                }
                
#if NS_BLOCKS_AVAILABLE
                if(self.cancelBlock) {
                    self.cancelBlock(self);
                }
#endif
            } else {
                if([_alertDelegate respondsToSelector:@selector(onClickAlertDlgConfirmButton:dialog:)]) {
                    [_alertDelegate onClickAlertDlgConfirmButton:sender dialog:self];
                }
                
#if NS_BLOCKS_AVAILABLE
                if(self.confirmBlock) {
                    self.confirmBlock(self);
                }
#endif
            }
        }
    }
    
    if(_inputTextField) {
        [_inputTextField resignFirstResponder];
    }
    
    if(self.autoCloseAfterClick) {
        [self hide:YES];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - keyboardNotification
- (void)txtkeyboardWillShow:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
        return;
    }
    
    NSDictionary *info = [notification userInfo];
    CGRect frame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyBoardsize  = frame.size;
    CGSize dlgSize = self.size;
    CGRect allRect = self.bounds;
    
    float bottomPosY = roundf((allRect.size.height - dlgSize.height) / 2) + self.yOffset + dlgSize.height;
    
    float distance = keyBoardsize.height + kInputKeyboardMargin -  (allRect.size.height - bottomPosY);
    
    if(distance > 0 && dlgSize.height > 0) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.2f];
        CGRect frame = self.frame;
        frame.origin.y = -distance;
        self.frame = frame;
        [UIView commitAnimations];
    }
    
}

- (void)txtkeyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2f];
    CGRect frame = self.frame;
    frame.origin.y = 0;
    self.frame = frame;
    [UIView commitAnimations];
}

@end
