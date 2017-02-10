//
//  UIAssetCell.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

typedef enum : NSUInteger {
    UIAssetCellTypePhoto = 0,
    UIAssetCellTypeLivePhoto,
    UIAssetCellTypePhotoGif,
    UIAssetCellTypeVideo,
    UIAssetCellTypeAudio,
} UIAssetCellType;

@class UIAssetModel;
@interface UIAssetCell : UICollectionViewCell

@property (weak, nonatomic) UIButton *selectPhotoButton;
@property (nonatomic, strong) UIAssetModel *model;
@property (nonatomic, copy) void (^didSelectPhotoBlock)(BOOL);
@property (nonatomic, assign) UIAssetCellType type;
@property (nonatomic, assign) BOOL allowPickingGif;
@property (nonatomic, copy) NSString *representedAssetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;

@property (nonatomic, copy) NSString *photoSelImageName;
@property (nonatomic, copy) NSString *photoDefImageName;

@property (nonatomic, assign) BOOL showSelectBtn;

@end





@interface TZAssetCameraCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;

@end
