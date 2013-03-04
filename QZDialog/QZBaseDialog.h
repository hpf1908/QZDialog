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

/** 标识哪个view需要动态的高度，如果需要动态的高度，布局layouts时会先计算其他的view的size */
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

//上中下布局的顶部view，可以自定义
@property(nonatomic,retain) UIView *topView;

//上中下布局的中间view，可以自定义
@property(nonatomic,retain) UIView *centerView;

//上中下布局的底部view，可以自定义
@property(nonatomic,retain) UIView *bottomView;

//最小的尺寸
@property(nonatomic,assign) CGSize minSize;

@property(nonatomic,assign) BOOL   taskInProgress;

//是否在隐藏时将浮层removeFromsuper
@property(nonatomic,assign) BOOL   removeFromSuperViewOnHide;

//延迟展示的时间
@property(nonatomic,assign) float  graceTime;

//动画进入的类型
@property(nonatomic,assign) QZDialogAnimation animationType;

//动态计算高度的类型
@property(nonatomic,assign) QZAutoHeight autoHeightType;

//浮层底部的颜色
@property(nonatomic,retain) UIColor *color;

//浮动层底部的透明度
@property(nonatomic,assign) float opacity;

//遮罩层的透明度
@property(nonatomic,assign) float maskOpacity;

@property(nonatomic,assign) float minShowTime;

//浮层的外边距
@property(nonatomic,assign) CGFloat margin;

//是否固定宽度
@property(nonatomic,assign) float fixWidth;

//浮层的位置x偏移量
@property(nonatomic,assign) CGFloat yOffset;

//浮层的位置y偏移量
@property(nonatomic,assign) CGFloat xOffset;

//浮层内部距离topView的上内边距
@property(nonatomic,assign) CGFloat paddingTop;

//浮层内部的左内边距
@property(nonatomic,assign) CGFloat paddingLeft;

//浮层内部的右内边距
@property(nonatomic,assign) CGFloat paddingRight;

//topView和centerView的边距
@property(nonatomic,assign) CGFloat paddingTopCenter;

//centerView和bottomView的边距
@property(nonatomic,assign) CGFloat paddingCenterBottom;

//浮层内部距离bottomView的下内边距
@property(nonatomic,assign) CGFloat paddingBottom;

@property(nonatomic,assign) id<QZDialogDelegate> delegate;

//遮罩层的类型
@property(nonatomic,assign) QZDialogMaskType maskType;

//是否尽量保持正方形的展示
@property(nonatomic,assign) BOOL   square;

- (id)initWithView:(UIView *)view;

- (id)initWithWindow:(UIWindow *)window;

- (void)showWhileExecuting:(SEL)method onTarget:(id)target withObject:(id)object animated:(BOOL)animated;

//弹出浮层并在delay时间之后消失
- (void)show:(BOOL)animated hideAfterDelay:(float)delay;

//动画展示浮动层
- (void)show:(BOOL)animated;

//动画隐藏浮动层
- (void)hide:(BOOL)animated;

//在delay时间之后让浮动层消失
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
