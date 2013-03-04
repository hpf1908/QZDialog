//
//  QZDialog.h
//  HudDemo
//
//  Created by pengfei huang on 13-2-25.
//

#import "QZBaseDialog.h"
#import "QZAlertButtons.h"
#import <Foundation/Foundation.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define QZDialogLabelAlignmentCenter NSTextAlignmentCenter
#else
#define QZDialogLabelAlignmentCenter UITextAlignmentCenter
#endif

@class QZAlertDialog;

#if NS_BLOCKS_AVAILABLE
typedef void (^QZDialogClickEventBlock)(QZAlertDialog* dlg);
#endif

//@notice: 将常用的浮出层类型通过枚举区分，虽然说这样条件很多，但是类型少的话比较好统一修改，如果以后有比较特殊的浮出层建议创建新的类继承QZBaseDialog去实现,否则耦合太多了，维护比较困难
/**
 * 每种类型需要关注
 
   不同位置的view的创建
        setupTopView
        setupCenterView
        setupBottomView
   不同位置的尺寸，需要根据maxSize动态计算
        topSize
        centerSize
        bottomSize
 
   如果有特殊的属性还需要注意 updateUIForKeypath 的操作
 */

typedef enum {
	QZAlertConfirm,            //显示两个按钮
	QZAlertCancel,             //显示单个取消按钮
	QZAlertInput,              //带一个输入框外加两个按钮
    QZAlertProgress,           //显示进度条
    QZAlertProgressWithButton, //显示进度条，但是底部有按钮
    QZAlertTip,                //提示信息，上为uilabel，下为uilabel，中间放一张图片,该图片可以通过tipImage去设置
    QZAlertTipCustomInCenter   //提示信息，上为uilabel，下为uilabel，中间放customView
} QZAlertMode;

@protocol QZAlertDialogDelegate <NSObject>

@optional

//点击确定按钮时触发
- (void)onClickAlertDlgConfirmButton:(id)sender dialog:(QZAlertDialog*)dlg;

//点击取消按钮时触发，当只有一个按钮时响应这个方法
- (void)onClickAlertDlgCancelButton:(id)sender dialog:(QZAlertDialog*)dlg;

@end

@interface QZAlertDialog : QZBaseDialog<QZAlertButtonsDelegate,UITextFieldDelegate> {
    QZAlertMode _alertMode;
    NSString    *_inputText;
    id<QZAlertDialogDelegate> _alertDelegate;
    UITextField  *_inputTextField;
    UIView      *_customView;
    UIImage     *_dlgBackGroundImage;
}

@property (nonatomic,copy)   NSString    *title;
@property (nonatomic,copy)   NSString    *content;

//确定按钮的文字
@property (nonatomic,copy)   NSString    *confirmBtnText;

//取消按钮的文字
@property (nonatomic,copy)   NSString    *cancelBtnText;

//修改title的字体大小
@property (nonatomic,retain) UIFont      *titleFont;

//修改内容的字体大小
@property (nonatomic,retain) UIFont      *contentFont;

//浮层的模式
@property (nonatomic,assign) QZAlertMode alertMode;

//按钮的回调
@property (nonatomic,assign) id<QZAlertDialogDelegate> alertDelegate;

//指定是否点击按钮自动关闭浮层，默认为YES
@property (nonatomic,assign) BOOL     autoCloseAfterClick;

//当alertMode为QZAlertTip时，可以通过该方法获设置中间的图片，尺寸最好是156*156
@property (nonatomic,retain) UIImage     *tipImage;

//浮层背景图片的修改
@property (nonatomic,retain) UIImage     *dlgBackGroundImage;

//当alertMode为QZAlertInput时，可以通过该方法获取用户输入的文本
@property (nonatomic,readonly) NSString  *inputText;

#pragma mark - class methods

//包含确认和取消按钮的确认对话框
+ (QZAlertDialog*)showConfirmDlgAddedTo:(UIView *)view
                               title:(NSString*)title
                             content:(NSString*)content
                            animated:(BOOL)animated
                          alertDelegate:(id<QZAlertDialogDelegate>)delegate;

//只包含取消按钮的确认对话框
+ (QZAlertDialog*)showCancelDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated
                          alertDelegate:(id<QZAlertDialogDelegate>)delegate;

//包含一个输入框和取消按钮的对话框
+ (QZAlertDialog*)showInputDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                        alertDelegate:(id<QZAlertDialogDelegate>)delegate;

//包含一个进度条提示条的浮层
+ (QZAlertDialog*)showProgressDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                                animated:(BOOL)animated;

//包含一个进度条提示条和取消按钮的浮层
+ (QZAlertDialog*)showProgressHasButtonDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                        alertDelegate:(id<QZAlertDialogDelegate>)delegate;

//包含一张图片的提示浮层
+ (QZAlertDialog*)showTipDlgAddedTo:(UIView *)view
                              title:(NSString*)title
                            content:(NSString*)content
                           animated:(BOOL)animated
                     hideAfterDelay:(float)delay;

//获取存在于指定view中的所有浮层
+ (NSArray *)allDlgsForView:(UIView *)view;

//隐藏所有指定view中的所有浮层
+ (NSUInteger)hideAllDlgsForView:(UIView *)view animated:(BOOL)animated;

+ (BOOL)hideDlgForView:(UIView *)view animated:(BOOL)animated;

+ (QZAlertDialog *)dlgForView:(UIView *)view;

#if NS_BLOCKS_AVAILABLE

+ (QZAlertDialog*)showConfirmDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated
                                confirm:(QZDialogClickEventBlock)confirmClick
                                 cancel:(QZDialogClickEventBlock)cancelClick;

+ (QZAlertDialog*)showCancelDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated
                                 cancel:(QZDialogClickEventBlock)cancelClick;

+ (QZAlertDialog*)showInputDlgAddedTo:(UIView *)view
                                 title:(NSString*)title
                               content:(NSString*)content
                              animated:(BOOL)animated
                              confirm:(QZDialogClickEventBlock)confirmClick
                               cancel:(QZDialogClickEventBlock)cancelClick;

+ (QZAlertDialog*)showProgressHasButtonDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                               cancel:(QZDialogClickEventBlock)cancelClick;

@property (copy) QZDialogClickEventBlock confirmBlock;
@property (copy) QZDialogClickEventBlock cancelBlock;

#endif

@end
