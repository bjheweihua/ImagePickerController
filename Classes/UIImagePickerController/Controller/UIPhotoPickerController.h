//
//  UIPhotoPickerController.h
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIAlbumModel;
@interface UIPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) UIAlbumModel *model;

@property (nonatomic, copy) void (^backButtonClickHandle)(UIAlbumModel *model);

@end


@interface JRCollectionView : UICollectionView

@end
