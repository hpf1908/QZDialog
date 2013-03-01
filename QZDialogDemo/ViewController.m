//
//  ViewController.m
//  QZDialogDemo
//
//  Created by pengfei huang on 13-2-27.
//  Copyright (c) 2013年 pengfei huang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"QZDialog Demo";
	UIView *content = [[self.view subviews] objectAtIndex:0];
	((UIScrollView *)content).contentSize = content.bounds.size;
	// Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	UIView *content = [[self.view subviews] objectAtIndex:0];
	((UIScrollView *)content).contentSize = content.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - dialog actions
- (IBAction)showWithConfirm:(id)sender {
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"标题栏";
	hud.content = @"内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容内容";
	hud.alertMode = QZAlertConfirm;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES];
}

- (IBAction)showWithCancel:(id)sender {
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"哈哈哈哈";
	hud.content = @"ddfdfdf";
	hud.alertMode = QZAlertCancel;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES];
}

- (IBAction)showWithInput:(id)sender {
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"请输入文字";
	hud.alertMode = QZAlertInput;
	hud.alertDelegate = self;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES];
}

- (IBAction)showWithProgress:(id)sender {
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
//	hud.title = @"正在加载视频";
    hud.title = nil;
    hud.content = @"正在加载视频";
	hud.alertMode = QZAlertProgress;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES hideAfterDelay:3.0f];
}

- (IBAction)showWithProgressButton:(id)sender
{
    QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"正在加载视频";
	hud.alertMode = QZAlertProgressWithButton;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES];
}

- (IBAction)showWithTip:(id)sender {
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"加入特别关心";
	hud.content = @"用电脑登陆查看吧";
	hud.alertMode = QZAlertTip;
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES hideAfterDelay:1.0f];
}

- (IBAction)showWithLabelMixed:(id)sender {
	
	QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.title = @"标题栏";
	hud.content = @"内容";
	hud.delegate = self;
	hud.alertMode = QZAlertConfirm;
	
    /***  前一个没执行完之前再调用当sleep时会crash，怀疑是sleep的用法问题 */
	[hud showWhileExecuting:@selector(dialogMixedTask:) onTarget:self withObject:hud animated:YES];
}

- (IBAction)showWithCustomInCenter:(id)sender
{
    QZAlertDialog* hud = [[QZAlertDialog alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:hud];
	hud.alertMode = QZAlertTipCustomInCenter;
    hud.content = @"haha";
    UIImage *check = [UIImage imageNamed:@"MB_Icon_Tips.png"];
    hud.centerView = [[UIImageView alloc] initWithImage:check];
	hud.removeFromSuperViewOnHide = YES;
	[hud show:YES hideAfterDelay:1.0f];
}

- (IBAction)showWithConfirmBlock:(id)sender
{
    [QZAlertDialog showConfirmDlgAddedTo:self.navigationController.view title:@"测试" content:@"测试block" animated:YES confirm:^(QZAlertDialog *dlg1) {
        NSLog(@"inputText confirm block %@",dlg1.inputText);
    } cancel:^(QZAlertDialog *dlg1) {
        NSLog(@"inputText cancel block %@",dlg1.inputText);
    }];
}

#pragma mark - task
- (void)simulateSleep
{
    sleep(2.0);
}

- (void)dialogMixedTask:(QZAlertDialog*)dialog {
    NSLog(@"begin mixed");
    // Indeterminate mode
    [self simulateSleep];
    // Switch to determinate mode
    dialog.title = @"哈哈哈哈";
    dialog.content = @"ddfdfdf";
    dialog.alertMode = QZAlertCancel;
    [self simulateSleep];
    dialog.title = @"请输入文字";
    dialog.alertMode = QZAlertInput;
    [self simulateSleep];
    dialog.title = @"正在加载视频";
    dialog.alertMode = QZAlertProgress;
    [self simulateSleep];
    dialog.title = @"发送成功";
    dialog.content = @"用电脑登陆查看吧";
    dialog.alertMode = QZAlertTip;
    [self simulateSleep];
    NSLog(@"end mixed");
}

#pragma mark - QZDialogDelegate
- (void)qzDialogWasHidden:(QZBaseDialog *)dialog
{
	[dialog removeFromSuperview];
    NSLog(@"qzDialogWasHidden");
}

#pragma mark - QZAlertDialogDelegate
- (void)onClickAlertDlgConfirmButton:(id)sender dialog:(QZAlertDialog*)dialog
{
	NSLog(@"inputText %@",dialog.inputText);
}

- (void)onClickAlertDlgCancelButton:(id)sender dialog:(QZAlertDialog*)dialog
{
	NSLog(@"inputText %@",dialog.inputText);
}

@end
