//
//  UIAssetModel.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UIAssetModelMediaTypePhoto = 0,
    UIAssetModelMediaTypeLivePhoto,
    UIAssetModelMediaTypePhotoGif,
    UIAssetModelMediaTypeVideo,
    UIAssetModelMediaTypeAudio
} UIAssetModelMediaType;

@class PHAsset;
@interface UIAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, assign) BOOL isSelected;      ///< The select status of a photo, default is No
@property (nonatomic, assign) UIAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(UIAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(UIAssetModelMediaType)type timeLength:(NSString *)timeLength;
@end
