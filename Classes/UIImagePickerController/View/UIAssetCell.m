//
//  UIAssetCell.m
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "UIAssetCell.h"
#import "UIAssetModel.h"
#import "UIAlbumModel.h"
#import "UIView+Layout.h"
#import "UIImageManager.h"
#import "UIImagePickerNaviController.h"
#import "UIJRProgressView.h"

@interface UIAssetCell ()
@property (weak, nonatomic) UIImageView *imageView;       // The photo / 照片
@property (weak, nonatomic) UIImageView *selectImageView;
@property (weak, nonatomic) UIView *bottomView;
@property (weak, nonatomic) UILabel *timeLength;

@property (nonatomic, weak) UIImageView *videoImgView;
@property (nonatomic, strong) UIJRProgressView *progressView;
@property (nonatomic, assign) PHImageRequestID bigImageRequestID;
@end

@implementation UIAssetCell

- (void)setModel:(UIAssetModel *)model {
    _model = model;
    if (iOS8Later) {
        self.representedAssetIdentifier = [[UIImageManager manager] getAssetIdentifier:model.asset];
    }
    PHImageRequestID imageRequestID = [[UIImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            self.progressView.hidden = YES;
            self.imageView.alpha = 1.0;
        }
        // Set the cell's thumbnail image if it's still showing the same asset.
        if (!iOS8Later) {
            self.imageView.image = photo; return;
        }
        if ([self.representedAssetIdentifier isEqualToString:[[UIImageManager manager] getAssetIdentifier:model.asset]]) {
            self.imageView.image = photo;
        } else {
            // NSLog(@"this cell is showing other asset");
            [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        }
        if (!isDegraded) {
            self.imageRequestID = 0;
        }
    } progressHandler:nil networkAccessAllowed:NO];
    if (imageRequestID && self.imageRequestID && imageRequestID != self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
        // NSLog(@"cancelImageRequest %d",self.imageRequestID);
    }
    self.imageRequestID = imageRequestID;
    self.selectPhotoButton.selected = model.isSelected;
    self.selectImageView.image = self.selectPhotoButton.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    self.type = (NSInteger)model.type;
    // 让宽度/高度小于 最小可选照片尺寸 的图片不能选中
    if (![[UIImageManager manager] isPhotoSelectableWithAsset:model.asset]) {
        if (_selectImageView.hidden == NO) {
            self.selectPhotoButton.hidden = YES;
            _selectImageView.hidden = YES;
        }
    }
    // 如果用户选中了该图片，提前获取一下大图
    if (model.isSelected) {
        [self fetchBigImage];
    }
}

- (void)setShowSelectBtn:(BOOL)showSelectBtn {
    _showSelectBtn = showSelectBtn;
    if (!self.selectPhotoButton.hidden) {
        self.selectPhotoButton.hidden = !showSelectBtn;
    }
    if (!self.selectImageView.hidden) {
        self.selectImageView.hidden = !showSelectBtn;
    }
}

- (void)setType:(UIAssetCellType)type {
    _type = type;
    if (type == UIAssetCellTypePhoto || type == UIAssetCellTypeLivePhoto || (type == UIAssetCellTypePhotoGif && !self.allowPickingGif)) {
        _selectImageView.hidden = NO;
        _selectPhotoButton.hidden = NO;
        _bottomView.hidden = YES;
    } else { // Video of Gif
        _selectImageView.hidden = YES;
        _selectPhotoButton.hidden = YES;
        _bottomView.hidden = NO;
        if (type == UIAssetCellTypeVideo) {
            self.timeLength.text = _model.timeLength;
            self.videoImgView.hidden = NO;
            _timeLength.tz_left = self.videoImgView.tz_right;
            _timeLength.textAlignment = NSTextAlignmentRight;
        } else {
            self.timeLength.text = @"GIF";
            self.videoImgView.hidden = YES;
            _timeLength.tz_left = 5;
            _timeLength.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.isSelected);
    }
    self.selectImageView.image = sender.isSelected ? [UIImage imageNamedFromMyBundle:self.photoSelImageName] : [UIImage imageNamedFromMyBundle:self.photoDefImageName];
    if (sender.isSelected) {
        [UIView showOscillatoryAnimationWithLayer:_selectImageView.layer type:UIOscillatoryAnimationToBigger];
        // 用户选中了该图片，提前获取一下大图
        [self fetchBigImage];
    } else { // 取消选中，取消大图的获取
        if (_bigImageRequestID && _progressView) {
            [[PHImageManager defaultManager] cancelImageRequest:_bigImageRequestID];
            [self hideProgressView];
        }
    }
}

- (void)hideProgressView {
    self.progressView.hidden = YES;
    self.imageView.alpha = 1.0;
}

- (void)fetchBigImage {
    _bigImageRequestID = [[UIImageManager manager] getPhotoWithAsset:_model.asset completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        if (_progressView) {
            [self hideProgressView];
        }
    } progressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        if (_model.isSelected) {
            progress = progress > 0.02 ? progress : 0.02;;
            self.progressView.progress = progress;
            self.progressView.hidden = NO;
            self.imageView.alpha = 0.4;
        } else {
            *stop = YES;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } networkAccessAllowed:YES];
}

#pragma mark - Lazy load

- (UIButton *)selectPhotoButton {
    if (_selectImageView == nil) {
        UIButton *selectPhotoButton = [[UIButton alloc] init];
        selectPhotoButton.frame = CGRectMake(self.tz_width - 44, 0, 44, 44);
        [selectPhotoButton addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:selectPhotoButton];
        _selectPhotoButton = selectPhotoButton;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.tz_width, self.tz_height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
        
        [self.contentView bringSubviewToFront:_selectImageView];
        [self.contentView bringSubviewToFront:_bottomView];
    }
    return _imageView;
}

- (UIImageView *)selectImageView {
    if (_selectImageView == nil) {
        UIImageView *selectImageView = [[UIImageView alloc] init];
        selectImageView.frame = CGRectMake(self.tz_width - 27, 0, 27, 27);
        selectImageView.contentMode = UIViewContentModeScaleAspectFill;
        selectImageView.clipsToBounds = YES;
        [self.contentView addSubview:selectImageView];
        _selectImageView = selectImageView;
    }
    return _selectImageView;
}

- (UIView *)bottomView {
    if (_bottomView == nil) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0, self.tz_height - 17, self.tz_width, 17);
        static NSInteger rgb = 0;
        bottomView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:0.8];
        [self.contentView addSubview:bottomView];
        _bottomView = bottomView;
    }
    return _bottomView;
}

- (UIImageView *)videoImgView {
    if (_videoImgView == nil) {
        UIImageView *videoImgView = [[UIImageView alloc] init];
        videoImgView.frame = CGRectMake(8, 0, 17, 17);
        [videoImgView setImage:[UIImage imageNamedFromMyBundle:@"VideoSendIcon.png"]];
        [self.bottomView addSubview:videoImgView];
        videoImgView.contentMode = UIViewContentModeScaleAspectFill;
        videoImgView.clipsToBounds = YES;
        _videoImgView = videoImgView;
    }
    return _videoImgView;
}

- (UILabel *)timeLength {
    if (_timeLength == nil) {
        UILabel *timeLength = [[UILabel alloc] init];
        timeLength.font = [UIFont boldSystemFontOfSize:11];
        timeLength.frame = CGRectMake(self.videoImgView.tz_right, 0, self.tz_width - self.videoImgView.tz_right - 5, 17);
        timeLength.textColor = [UIColor whiteColor];
        timeLength.textAlignment = NSTextAlignmentRight;
        [self.bottomView addSubview:timeLength];
        _timeLength = timeLength;
    }
    return _timeLength;
}

- (UIJRProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIJRProgressView alloc] init];
        static CGFloat progressWH = 20;
        CGFloat progressXY = (self.tz_width - progressWH) / 2;
        _progressView.hidden = YES;
        _progressView.frame = CGRectMake(progressXY, progressXY, progressWH, progressWH);
        [self addSubview:_progressView];
    }
    return _progressView;
}

@end





@implementation TZAssetCameraCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.500];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _imageView.frame = self.bounds;
}

@end
