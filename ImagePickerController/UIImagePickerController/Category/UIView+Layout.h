//
//  UIView+Layout.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIOscillatoryAnimationToBigger,
    UIOscillatoryAnimationToSmaller,
} UIOscillatoryAnimationType;

@interface UIView (Layout)

@property (nonatomic) CGFloat tz_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat tz_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat tz_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat tz_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat tz_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat tz_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat tz_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat tz_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint tz_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  tz_size;        ///< Shortcut for frame.size.

+ (void)showOscillatoryAnimationWithLayer:(CALayer *)layer type:(UIOscillatoryAnimationType)type;

@end
