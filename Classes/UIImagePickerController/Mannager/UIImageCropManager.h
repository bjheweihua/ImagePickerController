//
//  UIImageCropManager.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageCropManager : NSObject

/// 裁剪框背景的处理
+ (void)overlayClippingWithView:(UIView *)view cropRect:(CGRect)cropRect containerView:(UIView *)containerView needCircleCrop:(BOOL)needCircleCrop;

/*
 1.7.2 为了解决多位同学对于图片裁剪的需求，我这两天有空便在研究图片裁剪
 幸好有tuyou的PhotoTweaks库做参考，裁剪的功能实现起来简单许多
 该方法和其内部引用的方法基本来自于tuyou的PhotoTweaks库，我做了稍许删减和修改
 感谢tuyou同学在github开源了优秀的裁剪库PhotoTweaks，表示感谢
 PhotoTweaks库的github链接：https://github.com/itouch2/PhotoTweaks
 */
/// 获得裁剪后的图片
+ (UIImage *)cropImageView:(UIImageView *)imageView toRect:(CGRect)rect zoomScale:(double)zoomScale containerView:(UIView *)containerView;

/// 获取圆形图片
+ (UIImage *)circularClipImage:(UIImage *)image;

@end


/// 该分类的代码来自SDWebImage:https://github.com/rs/SDWebImage
/// 为了防止冲突，我将分类名字和方法名字做了修改
@interface UIImage (UIGif)

+ (UIImage *)sd_tz_animatedGIFWithData:(NSData *)data;

@end
