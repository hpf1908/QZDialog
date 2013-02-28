//
//  ViewController.h
//  QZDialogDemo
//
//  Created by pengfei huang on 13-2-27.
//  Copyright (c) 2013年 pengfei huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QZAlertDialog.h"

@interface ViewController : UIViewController <QZDialogDelegate,QZAlertDialogDelegate> {
    QZAlertDialog* dlg;
}


- (IBAction)showWithConfirm:(id)sender;
- (IBAction)showWithCancel:(id)sender;
- (IBAction)showWithInput:(id)sender;
- (IBAction)showWithProgress:(id)sender;
- (IBAction)showWithProgressButton:(id)sender;
- (IBAction)showWithTip:(id)sender;
- (IBAction)showWithLabelMixed:(id)sender;
- (IBAction)showWithCustomInCenter:(id)sender;

- (IBAction)showWithConfirmBlock:(id)sender;

@end
