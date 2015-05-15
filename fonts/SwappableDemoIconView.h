//
//  SwappableDemoIconView.h
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface SwappableDemoIconView : UIView

@property (strong, nonatomic) IBInspectable NSString * icon;
@property (strong, nonatomic) IBInspectable UIColor * fontColor;

@end