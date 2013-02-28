//
//  QZDialog.h
//  HudDemo
//
//  Created by pengfei huang on 13-2-25.
//


/******************************************************
 @todo: 先用nonarc实现，再改为arc实现
 1. title、content、bottom分别可以支持自定义
 2. 背景支持自定义配置
 3. 动画也需要可以配置
 4. 预留abstract函数用于自定义配置
 ******************************************************/

#import <Foundation/Foundation.h>

@protocol QZDialogDelegate;

#if NS_BLOCKS_AVAILABLE
typedef void (^QZDialogCompletionBlock)();
#endif

typedef enum {
	/** Opacity animation */
	QZDialogAnimationFade,
	/** Opacity + scale animation */
	QZDialogAnimationZoom,
	QZDialogAnimationZoomOut = QZDialogAnimationZoom,
	QZDialogAnimationZoomIn
} QZDialogAnimation;

/** 标识哪个view需要自动填充高度 */
typedef enum {
	QZAutoHeightNone,
	QZAutoHeightTop,
	QZAutoHeightCenter,
	QZAutoHeightBottom
} QZAutoHeight;

/** 遮罩层的效果 **/
typedef enum {
    QZDialogMaskNone,
	QZDialogMaskOpacity,
	QZDialogMaskGradient
} QZDialogMaskType;

@interface QZBaseDialog : UIView {
    UIView    *_topView;
    UIView    *_centerView;
    UIView    *_bottomView;
    id<QZDialogDelegate> _delegate;
}

@property(nonatomic,retain) UIView *topView;
@property(nonatomic,retain) UIView *centerView;
@property(nonatomic,retain) UIView *bottomView;
@property(nonatomic,assign) CGSize minSize;
@property(nonatomic,assign) BOOL   taskInProgress;
@property(nonatomic,assign) BOOL   removeFromSuperViewOnHide;
@property(nonatomic,assign) float  graceTime;
@property(nonatomic,assign) QZDialogAnimation animationType;
@property(nonatomic,assign) QZAutoHeight autoHeightType;
@property(nonatomic,retain) UIColor *color;
@property(nonatomic,assign) float opacity;
@property(nonatomic,assign) float maskOpacity;
@property(nonatomic,assign) float minShowTime;
@property(nonatomic,assign) CGFloat margin;
@property(nonatomic,assign) float fixWidth;
@property(nonatomic,assign) CGFloat yOffset;
@property(nonatomic,assign) CGFloat xOffset;
@property(nonatomic,assign) CGFloat paddingTop;
@property(nonatomic,assign) CGFloat paddingLeft;
@property(nonatomic,assign) CGFloat paddingRight;
@property(nonatomic,assign) CGFloat paddingTopCenter;
@property(nonatomic,assign) CGFloat paddingCenterBottom;
@property(nonatomic,assign) CGFloat paddingBottom;
@property(nonatomic,assign) id<QZDialogDelegate> delegate;
@property(nonatomic,assign) QZDialogMaskType maskType;
@property(nonatomic,assign) BOOL   square;

- (id)initWithView:(UIView *)view;

- (id)initWithWindow:(UIWindow *)window;

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

- (void)show:(BOOL)animated hideAfterDelay:(float)delay;

- (void)show:(BOOL)animated;

- (void)hide:(BOOL)animated;

- (void)hide:(BOOL)animated afterDelay:(NSTimeInterval)delay;

- (void)cleanUp;

#if NS_BLOCKS_AVAILABLE
- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block completionBlock:(QZDialogCompletionBlock)completion;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue;

- (void)showAnimated:(BOOL)animated whileExecutingBlock:(dispatch_block_t)block onQueue:(dispatch_queue_t)queue
     completionBlock:(QZDialogCompletionBlock)completion;

@property (copy) QZDialogCompletionBlock completionBlock;

#endif

@end

@protocol QZDialogDelegate <NSObject>

@optional

- (void)qzDialogWasHidden:(QZBaseDialog *)dlg;

@end
