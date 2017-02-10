//
//  UITestCell.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITestCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, strong) UILabel *gifLable;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) id asset;

- (UIView *)snapshotView;
@end
