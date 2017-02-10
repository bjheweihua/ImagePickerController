//
//  UIAssetModel.m
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "UIAssetModel.h"

@implementation UIAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(UIAssetModelMediaType)type{
    UIAssetModel *model = [[UIAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(UIAssetModelMediaType)type timeLength:(NSString *)timeLength {
    UIAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

@end
