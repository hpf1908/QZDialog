//
//  QZDialog.m
//  HudDemo
//
//  Created by pengfei huang on 13-2-25.
//

#import "QZBaseDialog.h"

@interface QZBaseDialog(){
    BOOL useAnimation;
    SEL methodForExecution;
    id targetForExecution;
    id objectForExecution;
    BOOL isFinished;
    CGAffineTransform rotationTransform;
}

@property(nonatomic,assign) CGSize  size;

@property(atomic,retain) NSTimer *graceTimer;
@property(nonatomic,retain) NSDate *showStarted;
@property(atomic, retain) NSTimer *minShowTimer;

- (void)registerForKVO;
- (void)unregisterFromKVO;
- (void)registerForNotifications;
- (void)unregisterFromNotifications;

- (NSArray *)observableKeypaths;
- (BOOL)updateUIForKeypath:(NSString *)keyPath;

@end

@implementation QZBaseDialog

@synthesize topView   = _topView;
@synthesize centerView = _centerView;
@synthesize bottomView  = _bottomView;
@synthesize minSize;
@synthesize size;
@synthesize margin;
@synthesize xOffset;
@synthesize yOffset;
@synthesize paddingTop;
@synthesize paddingLeft;
@synthesize paddingRight;
@synthesize paddingTopCenter;
@synthesize paddingCenterBottom;
@synthesize paddingBottom;
@synthesize taskInProgress;
@synthesize removeFromSuperViewOnHide;
@synthesize graceTime;
@synthesize graceTimer;
@synthesize showStarted;
@synthesize color;
@synthesize animationType;
@synthesize opacity;
@synthesize minShowTime;
@synthesize autoHeightType;
@synthesize minShowTimer;
@synthesize fixWidth;
@synthesize maskOpacity;
@synthesize completionBlock;
@synthesize maskType;
@synthesize delegate = _delegate;
@synthesize square;

#pragma mark - Lifecycle

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        self.minSize = CGSizeZero;
        self.xOffset = 0.0f;
		self.yOffset = 0.0f;
        
        self.fixWidth = 0.0f;
        self.paddingTop = 15.0;
        self.paddingBottom = 15.0;
        self.paddingLeft = 15.0;
        self.paddingRight = 15.0;
        
        self.paddingTopCenter = 15.0;
        self.paddingCenterBottom = 15.0;
        
        self.square = NO;
        self.maskType = QZDialogMaskOpacity;
        self.maskOpacity = 0.0;
        self.opacity = 0.8f;
        self.graceTime = 0.0f;
		self.minShowTime = 0.0f;
        self.removeFromSuperViewOnHide = NO;
        self.color = nil;
        // Transparent background
		self.opaque = NO;
        self.margin = 20.0f;
        self.autoHeightType = QZAutoHeightCenter;
		self.backgroundColor = [UIColor clearColor];
		// Make it invisible for now
		self.alpha = 0.0f;
		
		taskInProgress = NO;
		rotationTransform = CGAffineTransformIdentity;
        
        [self registerForKVO];
		[self registerForNotifications];
    }
	return self;
}

- (id)initWithView:(UIView *)view {
	NSAssert(view, @"View must not be nil.");
	return [self initWithFrame:view.bounds];
}

- (id)initWithWindow:(UIWindow *)window {
	return [self initWithView:window];
}

- (void)dealloc {
	[self unregisterFromNotifications];
	[self unregisterFromKVO];
	self.color = nil;
    self.topView = nil;
    self.centerView = nil;
    self.bottomView = nil;
	[graceTimer release];
	[minShowTimer release];
	[showStarted release];
	[super dealloc];
    
    NSLog(@"dealloc QZBaseDialog");
}

- (void)layoutSubviews
{
    // Entirely cover the parent view
	UIView *parent = self.superview;
	if (parent) {
		self.frame = parent.bounds;
	}
    
	CGSize totalSize = CGSizeZero;
	CGRect bounds = self.bounds;
    CGSize topSize   = CGSizeZero;
    CGSize centerSize = CGSizeZero;
    CGSize bottomSize  = CGSizeZero;
    
    //子view允许的最大尺寸
    CGSize maxSize = CGSizeMake(bounds.size.width - 2 * margin - paddingLeft - paddingRight, bounds.size.height - totalSize.height  - 2 * margin - paddingTop - paddingBottom);
    
    //固定宽度
    float maxWrapWidth = maxSize.width + paddingLeft + paddingRight;
    
    if(self.fixWidth > 0 && self.fixWidth <= maxWrapWidth ) {
        maxSize.width = self.fixWidth - paddingLeft - paddingRight;
    }
    
    if(self.topView && self.autoHeightType != QZAutoHeightTop) {
        topSize = [self topSize:maxSize];
        topSize.width = MIN(maxSize.width, topSize.width);
        totalSize.width = MAX(totalSize.width, topSize.width);
        totalSize.height += topSize.height;
        maxSize.height -= topSize.height;
    }
    
    if(self.centerView && self.autoHeightType != QZAutoHeightCenter) {
        centerSize = [self centerSize:maxSize];
        centerSize.width = MIN(maxSize.width, centerSize.width);
        totalSize.width = MAX(totalSize.width, centerSize.width);
        
        if(centerSize.height > 0) {
            if(self.topView) {
                maxSize.height -= paddingTopCenter;
                totalSize.height+= paddingTopCenter;
            }
        }
        totalSize.height += centerSize.height;
        maxSize.height-= centerSize.height;
    }
    
    if(self.bottomView && self.autoHeightType != QZAutoHeightBottom) {
        bottomSize = [self bottomSize:maxSize];
        bottomSize.width = MIN(maxSize.width, bottomSize.width);
        totalSize.width = MAX(totalSize.width, bottomSize.width);
        
        if(bottomSize.height > 0) {
            if(self.centerView) {
                maxSize.height -= paddingCenterBottom;
                totalSize.height+= paddingCenterBottom;
            } else if(self.topView) {
                maxSize.height -= paddingTopCenter;
                totalSize.height+= paddingTopCenter;
            }
        }
        totalSize.height += bottomSize.height;
        maxSize.height -= bottomSize.height;
    }
    
    if(self.autoHeightType == QZAutoHeightTop) {
        topSize = [self topSize:maxSize];
        topSize.width = MIN(maxSize.width, topSize.width);
        totalSize.width = MAX(totalSize.width, topSize.width);
        totalSize.height += topSize.height;
        maxSize.height -= topSize.height;
    } else if(self.autoHeightType == QZAutoHeightCenter) {
        
        centerSize = [self centerSize:maxSize];
        centerSize.width = MIN(maxSize.width, centerSize.width);
        totalSize.width = MAX(totalSize.width, centerSize.width);
        
        if(centerSize.height > 0) {
            if(self.topView) {
                maxSize.height -= paddingTopCenter;
                totalSize.height+= paddingTopCenter;
            }
        }
        totalSize.height += centerSize.height;
        maxSize.height-= centerSize.height;
    } else if(self.autoHeightType == QZAutoHeightBottom) {
        bottomSize = [self bottomSize:maxSize];
        bottomSize.width = MIN(maxSize.width, bottomSize.width);
        totalSize.width = MAX(totalSize.width, bottomSize.width);
        
        if(bottomSize.height > 0) {
            if(self.centerView) {
                maxSize.height -= paddingCenterBottom;
                totalSize.height+= paddingCenterBottom;
            } else if(self.topView) {
                maxSize.height -= paddingTopCenter;
                totalSize.height+= paddingTopCenter;
            }
        }  
        totalSize.height += bottomSize.height;
    }
    
    if(self.fixWidth > 0) {
        totalSize.width = maxSize.width;
    }
    
    totalSize.width += paddingLeft + paddingRight;
	totalSize.height += paddingTop + paddingBottom;
    
    // Position elements
	CGFloat yPos = roundf(((bounds.size.height - totalSize.height) / 2)) + paddingTop + yOffset;
	CGFloat xPos = xOffset;
    
    if(self.topView) {
        CGRect titleRect = CGRectZero;
        titleRect.origin.x = roundf((bounds.size.width - topSize.width) / 2) + xPos;
        titleRect.origin.y = yPos;
        titleRect.size.width = topSize.width;
        titleRect.size.height = topSize.height;
        self.topView.frame = titleRect;
        yPos+= topSize.height;
    }
    
    if(self.centerView) {
        CGRect contentRect = CGRectZero;
        contentRect.origin.x = roundf((bounds.size.width - centerSize.width) / 2) + xPos;
        
        if(self.topView && centerSize.height > 0) {
            yPos+= paddingTopCenter;
        }
        
        contentRect.origin.y = yPos;
        contentRect.size.width = centerSize.width;
        contentRect.size.height = centerSize.height;
        self.centerView.frame = contentRect;
        yPos+= centerSize.height;
    }
    
    if(self.bottomView) {
        CGRect bottomRect = CGRectZero;
        bottomRect.origin.x = roundf((bounds.size.width - bottomSize.width) / 2) + xPos;
        
        if(bottomSize.height > 0) {
            if(self.centerView) {
                yPos+= paddingCenterBottom;
            } else if(self.topView) {
                yPos+= paddingTopCenter;
            }
        }
        
        bottomRect.origin.y = yPos;
        bottomRect.size.width = bottomSize.width;
        bottomRect.size.height = bottomSize.height;
        self.bottomView.frame = bottomRect;
        yPos+= centerSize.height;
    }
    
    // Enforce minsize and quare rules
	if (square) {
		CGFloat max = MAX(totalSize.width, totalSize.height);
		if (max <= bounds.size.width - 2 * margin) {
			totalSize.width = max;
		}
		if (max <= bounds.size.height - 2 * margin) {
			totalSize.height = max;
		}
	}
    
    if (totalSize.width < minSize.width) {
		totalSize.width = minSize.width;
	}
	if (totalSize.height < minSize.height) {
		totalSize.height = minSize.height;
	}
    
    self.size = totalSize;
}

- (void)drawRect:(CGRect)rect
{
    if(self.maskType == QZDialogMaskOpacity) {
        [self drawOpacityMaskBackView];
    } else if(self.maskType == QZDialogMaskGradient){
        [self drawGardiantBackView];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    // Set background rect color
    if (self.color) {
        CGContextSetFillColorWithColor(context, self.color.CGColor);
    } else {
        CGContextSetGrayFillColor(context, 0.0f, self.opacity);
    }
    
	// Center HUD
	CGRect allRect = self.bounds;
	// Draw rounded HUD backgroud rect
	CGRect boxRect = CGRectMake(roundf((allRect.size.width - size.width) / 2) + self.xOffset,
								roundf((allRect.size.height - size.height) / 2) + self.yOffset, size.width, size.height);
	float radius = 10.0f;
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect));
	CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMinY(boxRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
	CGContextAddArc(context, CGRectGetMaxX(boxRect) - radius, CGRectGetMaxY(boxRect) - radius, radius, 0, (float)M_PI / 2, 0);
	CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMaxY(boxRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
	CGContextAddArc(context, CGRectGetMinX(boxRect) + radius, CGRectGetMinY(boxRect)  + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
	CGContextClosePath(context);
	CGContextFillPath(context);
    
	UIGraphicsPopContext();
}

- (void)drawGardiantBackView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    //Gradient colours
    size_t gradLocationsNum = 2;
    CGFloat gradLocations[2] = {0.0f, 1.0f};
    CGFloat gradColors[8] = {0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.0f,0.75f};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, gradColors, gradLocations, gradLocationsNum);
    CGColorSpaceRelease(colorSpace);
    //Gradient center
    CGPoint gradCenter= CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    //Gradient radius
    float gradRadius = MIN(self.bounds.size.width , self.bounds.size.height) ;
    //Gradient draw
    CGContextDrawRadialGradient (context, gradient, gradCenter,
                                 0, gradCenter, gradRadius,
                                 kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    
    UIGraphicsPopContext();
}

- (void)drawOpacityMaskBackView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
    
    CGContextSetGrayFillColor(context, 0.0f, self.maskOpacity);
    
	CGRect backRect = self.bounds;
    float radius = 0.0f;
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(backRect), CGRectGetMinY(backRect));
    CGContextAddArc(context, CGRectGetMaxX(backRect) - radius, CGRectGetMinY(backRect) + radius, radius, 3 * (float)M_PI / 2, 0, 0);
	CGContextAddArc(context, CGRectGetMaxX(backRect) - radius, CGRectGetMaxY(backRect) - radius, radius, 0, (float)M_PI / 2, 0);
	CGContextAddArc(context, CGRectGetMinX(backRect) + radius, CGRectGetMaxY(backRect) - radius, radius, (float)M_PI / 2, (float)M_PI, 0);
	CGContextAddArc(context, CGRectGetMinX(backRect) + radius, CGRectGetMinY(backRect) + radius, radius, (float)M_PI, 3 * (float)M_PI / 2, 0);
    
	CGContextClosePath(context);
	CGContextFillPath(context);
    
	UIGraphicsPopContext();
}

#pragma mark - should ovverride
- (CGSize)topSize:(CGSize)maxSize
{
    return CGSizeZero;
}

- (CGSize)centerSize:(CGSize)maxSize
{
    return CGSizeZero;
}

- (CGSize)bottomSize:(CGSize)maxSize
{
    return CGSizeZero;
}

#pragma mark - viewSetter

- (void)setTopView:(UIView *)topView
{
    if(self.topView != topView) {
        [self.topView removeFromSuperview];
        [self.topView release];
        
        _topView = [topView retain];
        [self addSubview:_topView];
        [self refresh];
    }

}

- (void)setCenterView:(UIView *)centerView
{
    if(self.centerView != centerView) {
        [self.centerView removeFromSuperview];
        [self.centerView release];
        
        _centerView = [centerView retain];
        [self addSubview:_centerView];
        [self refresh];
    }
}

- (void)setBottomView:(UIView *)bottomView
{
    if(self.bottomView != bottomView) {
        [self.bottomView removeFromSuperview];
        [self.bottomView release];
        
        _bottomView = [bottomView retain];
        [self addSubview:_bottomView];
        [self refresh];
    }
}

#pragma mark - KVO

- (void)registerForKVO
{
    for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO
{
    for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths
{
	return [NSArray arrayWithObjects: @"topView", @"centerView", @"bottomView", @"yOffset", @"xOffset" ,nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(updateUIForKeypathInMainThread:) withObject:keyPath waitUntilDone:NO];
	} else {
        [self updateUIForKeypathInMainThread:keyPath];
	}
}

- (void)updateUIForKeypathInMainThread:(NSString *)keyPath
{
    BOOL shouldRefresh = [self updateUIForKeypath:keyPath];
    if(shouldRefresh) {
        [self refresh];
    }
}

- (BOOL)updateUIForKeypath:(NSString *)keyPath
{
    return YES;
}

- (void)refresh
{
    [self setNeedsLayout];
	[self setNeedsDisplay];
}

#pragma mark - Show & hide
- (void)show:(BOOL)animated hideAfterDelay:(float)delay
{
    [self show:animated];
    [self hide:animated afterDelay:delay];
}

- (void)show:(BOOL)animated {
	useAnimation = animated;
	// If the grace time is set postpone the HUD display
	if (self.graceTime > 0.0) {
		self.graceTimer = [NSTimer scheduledTimerWithTimeInterval:self.graceTime target:self
                                                         selector:@selector(handleGraceTimer:) userInfo:nil repeats:NO];
	}
	// ... otherwise show the HUD imediately
	else {
		[self setNeedsDisplay];
		[self showUsingAnimation:useAnimation];
	}
}

- (void)showUsingAnimation:(BOOL)animated {
	if (animated && animationType == QZDialogAnimationZoomIn) {
		self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
	} else if (animated && animationType == QZDialogAnimationZoomOut) {
		self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
	}
	self.showStarted = [NSDate date];
	// Fade in
	if (animated) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.30];
		self.alpha = 1.0f;
		if (animationType == QZDialogAnimationZoomIn || animationType == QZDialogAnimationZoomOut) {
			self.transform = rotationTransform;
		}
		[UIView commitAnimations];
	}
	else {
		self.alpha = 1.0f;
	}
}

- (void)hideUsingAnimation:(BOOL)animated {
	// Fade out
    self.showStarted = nil;
    
	if (animated && showStarted) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.30];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		// 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
		// in the done method
		if (animationType == QZDialogAnimationZoomIn) {
			self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(1.5f, 1.5f));
		} else if (animationType == QZDialogAnimationZoomOut) {
			self.transform = CGAffineTransformConcat(rotationTransform, CGAffineTransformMakeScale(0.5f, 0.5f));
		}
        
		self.alpha = 0.02f;
		[UIView commitAnimations];
	}
	else {
		self.alpha = 0.0f;
		[self done];
	}

}

- (void)hide:(BOOL)animated {
	useAnimation = animated;
	// If the minShow time is set, calculate how long the hud was shown,
	// and pospone the hiding operation if necessary
	if (self.minShowTime > 0.0 && showStarted) {
		NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:showStarted];
		if (interv < self.minShowTime) {
			self.minShowTimer = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self
                                                               selector:@selector(handleMinShowTimer:) userInfo:nil repeats:NO];
			return;
		}
	}
	// ... otherwise hide the HUD immediately
	[self hideUsingAnimation:useAnimation];
}

- (void)handleMinShowTimer:(NSTimer *)theTimer {
	[self hideUsingAnimation:useAnimation];
}

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay {
	[self performSelector:@selector(hideDelayed:) withObject:[NSNumber numberWithBool:animated] afterDelay:delay];
}

- (void)hideDelayed:(NSNumber *)animated {
	[self hide:[animated boolValue]];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
	[self done];
}

- (void)done {
	isFinished = YES;
	self.alpha = 0.0f;
    
#if NS_BLOCKS_AVAILABLE
	if (self.completionBlock) {
		self.completionBlock();
		self.completionBlock = NULL;
	}
#endif
    
    if (removeFromSuperViewOnHide) {
		[self removeFromSuperview];
	}
    
    if ([_delegate respondsToSelector:@selector(qzDialogWasHidden:)]) {
		[_delegate performSelector:@selector(qzDialogWasHidden:) withObject:self];
	}
}

#pragma mark - showWithBlocks

#if NS_BLOCKS_AVAILABLE

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	[self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(void (^)())completion {
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	[self showAnimated:animated whileExecutingBlock:block onQueue:queue completionBlock:completion];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue {
	[self showAnimated:animated whileExecutingBlock:block onQueue:queue	completionBlock:NULL];
}

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
	 completionBlock:(QZDialogCompletionBlock)completion {
	self.taskInProgress = YES;
	self.completionBlock = completion;
	dispatch_async(queue, ^(void) {
        block();
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self cleanUp];
        });
    });
    [self show:animated];
}

#endif


#pragma mark - Threading

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated {
	methodForExecution = method;
	targetForExecution = [target retain];
	objectForExecution = [object retain];
	// Launch execution in new thread
	self.taskInProgress = YES;
	[NSThread detachNewThreadSelector:@selector(launchExecution) toTarget:self withObject:nil];
	// Show HUD view
	[self show:animated];
}

- (void)launchExecution {
	@autoreleasepool {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		// Start executing the requested task
		[targetForExecution performSelector:methodForExecution withObject:objectForExecution];
#pragma clang diagnostic pop
		// Task completed, update view in main thread (note: view operations should
		// be done only in the main thread)
		[self performSelectorOnMainThread:@selector(cleanUp) withObject:nil waitUntilDone:NO];
	}
}

- (void)cleanUp {
	taskInProgress = NO;
#if !__has_feature(objc_arc)
	[targetForExecution release];
	[objectForExecution release];
#else
	targetForExecution = nil;
	objectForExecution = nil;
#endif
	[self hide:useAnimation];
}

#pragma mark - Notifications

- (void)registerForNotifications {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(deviceOrientationDidChange:)
			   name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)unregisterFromNotifications {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
	UIView *superview = self.superview;
	if (!superview) {
		return;
	} else if ([superview isKindOfClass:[UIWindow class]]) {
		[self setTransformForCurrentOrientation:YES];
	} else {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
}

- (void)setTransformForCurrentOrientation:(BOOL)animated {
	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat radians = 0;
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		if (orientation == UIInterfaceOrientationLandscapeLeft) { radians = -(CGFloat)M_PI_2; }
		else { radians = (CGFloat)M_PI_2; }
		// Window coordinates differ!
		self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
	} else {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) { radians = (CGFloat)M_PI; }
		else { radians = 0; }
	}
	rotationTransform = CGAffineTransformMakeRotation(radians);
	
	if (animated) {
		[UIView beginAnimations:nil context:nil];
	}
	[self setTransform:rotationTransform];
	if (animated) {
		[UIView commitAnimations];
	}
}

@end
