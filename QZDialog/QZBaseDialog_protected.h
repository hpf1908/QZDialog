//
//  QZBaseDialog_protected.h
//  HudDemo
//
//  Created by pengfei huang on 13-2-26.
//

#import <Foundation/Foundation.h>
#import "QZBaseDialog.h"

@interface QZBaseDialog(QZBaseDialog_protected)

@property(nonatomic,assign) CGSize  size;

- (NSArray *)observableKeypaths;

- (BOOL)updateUIForKeypath:(NSString *)keyPath;

- (void)drawOpacityMaskBackView;

- (void)drawGardiantBackView;

- (void)registerForNotifications;

- (void)unregisterFromNotifications;

@end