//
//  UIAlbumCell.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/17.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlbumCellH (70.f)

@class UIAlbumModel;
@interface UIAlbumCell : UITableViewCell

@property (nonatomic, strong) UIAlbumModel *model;
@property (weak, nonatomic) UIButton *selectedCountButton;

@end
