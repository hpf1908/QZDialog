//
//  MBButtons.h
//  HudDemo
//
//  Created by pengfei huang on 13-2-21.
//

#import <UIKit/UIKit.h>

@protocol QZAlertButtonsDelegate <NSObject>

@optional

- (void)didClickAlertButton:(id)sender;

@end

@interface QZAlertButtons : UIView {
    NSArray *_buttons;
    NSMutableArray *_btnsArray;
    id<QZAlertButtonsDelegate> _delegate;
}

@property(nonatomic,assign) id<QZAlertButtonsDelegate> delegate;
@property(nonatomic,assign) float padding;

- (id)initWithFrame:(CGRect)frame buttons:(NSArray*)btns;

@end
