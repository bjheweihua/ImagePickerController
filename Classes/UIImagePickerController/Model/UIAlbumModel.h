//
//  UIAlbumModel.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class PHFetchResult;
@interface UIAlbumModel : NSObject

@property (nonatomic, strong) NSString *name;        ///< The album name
@property (nonatomic, assign) NSInteger count;       ///< Count of photos the album contain
@property (nonatomic, strong) id result;             ///< PHFetchResult<PHAsset> or ALAssetsGroup<ALAsset>

@property (nonatomic, strong) NSArray *models;
@property (nonatomic, strong) NSArray *selectedModels;
@property (nonatomic, assign) NSUInteger selectedCount;

@end

