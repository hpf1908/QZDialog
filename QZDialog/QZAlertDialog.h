//
//  QZDialog.h
//  HudDemo
//
//  Created by pengfei huang on 13-2-25.
//  Copyright (c) 2013年 Matej Bukovinski. All rights reserved.
//

#import "QZBaseDialog.h"
#import "QZAlertButtons.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define QZDialogLabelAlignmentCenter NSTextAlignmentCenter
#else
#define QZDialogLabelAlignmentCenter UITextAlignmentCenter
#endif

#import <Foundation/Foundation.h>

@class QZAlertDialog;

typedef enum {
	QZAlertConfirm,            //显示两个按钮
	QZAlertCancel,             //显示单个取消按钮
	QZAlertInput,              //带一个输入框外加两个按钮
    QZAlertProgress,           //显示进度条
    QZAlertProgressWithButton, //带有底部button的进度条
    QZAlertTip,                //中间指定为图片
    QZAlertTipCustomInCenter   //上为uilabel，下为uilabel，中间放customView
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

@end
