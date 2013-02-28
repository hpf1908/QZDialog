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

typedef enum {
	QZAlertConfirm,            //显示两个按钮
	QZAlertCancel,             //显示单个取消按钮
	QZAlertInput,              //带一个输入框外加两个按钮
    QZAlertProgress,           //显示进度条
    QZAlertProgressWithButton, //显示进度条，但是底部有按钮
    QZAlertTip,                //提示信息，上为uilabel，下为uilabel，中间放一张图片tipImage
    QZAlertTipCustomInCenter   //提示信息，上为uilabel，下为uilabel，中间放customView
} QZAlertMode;

@protocol QZAlertDialogDelegate <NSObject>

@optional

- (void)onClickAlertDlgConfirmButton:(id)sender dialog:(QZAlertDialog*)dlg;

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
@property (nonatomic,copy)   NSString    *confirmBtnText;
@property (nonatomic,copy)   NSString    *cancelBtnText;
@property (nonatomic,retain) UIFont      *titleFont;
@property (nonatomic,retain) UIFont      *contentFont;
@property (nonatomic,assign) QZAlertMode alertMode;
@property (nonatomic,assign) id<QZAlertDialogDelegate> alertDelegate;
@property (nonatomic,assign) BOOL     autoCloseAfterClick;
@property (nonatomic,retain) UIImage     *tipImage;
@property (nonatomic,retain) UIImage     *dlgBackGroundImage;
@property (nonatomic,readonly) NSString  *inputText;

#pragma mark - class methods
+ (QZAlertDialog*)showConfirmDlgAddedTo:(UIView *)view
                               title:(NSString*)title
                             content:(NSString*)content
                            animated:(BOOL)animated;

+ (QZAlertDialog*)showCancelDlgAddedTo:(UIView *)view
                                  title:(NSString*)title
                                content:(NSString*)content
                               animated:(BOOL)animated;

+ (QZAlertDialog*)showInputDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                        alertDelegate:(id<QZAlertDialogDelegate>)delegate;

+ (QZAlertDialog*)showProgressDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                                animated:(BOOL)animated;

+ (QZAlertDialog*)showProgressHasButtonDlgAddedTo:(UIView *)view
                                title:(NSString*)title
                              content:(NSString*)content
                             animated:(BOOL)animated
                        alertDelegate:(id<QZAlertDialogDelegate>)delegate;

+ (QZAlertDialog*)showTipDlgAddedTo:(UIView *)view
                              title:(NSString*)title
                            content:(NSString*)content
                           animated:(BOOL)animated
                     hideAfterDelay:(float)delay;

+ (NSArray *)allDlgsForView:(UIView *)view;

+ (NSUInteger)hideAllHUDsForView:(UIView *)view animated:(BOOL)animated;

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
