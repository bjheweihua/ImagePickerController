//
//  UIAlbumCell.m
//  ImagePickerController
//
//  Created by heweihua on 2017/1/17.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "UIAlbumCell.h"
//#import "UIAssetModel.h"
#import "UIAlbumModel.h"
#import "UIView+Layout.h"
#import "UIImageManager.h"
#import "UIImagePickerNaviController.h"
//#import "UIJRProgressView.h"
#import "UIColor+Additions.h"

// Screen Size
#define UIScreen_W CGRectGetWidth([[UIScreen mainScreen] bounds])
#define UIScreen_H CGRectGetHeight([[UIScreen mainScreen] bounds])

@interface UIAlbumCell ()
@property (weak, nonatomic) UIImageView *posterImageView;
@property (weak, nonatomic) UILabel *titleLable;
@property (weak, nonatomic) UIImageView *arrowImageView;
@end

@implementation UIAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.contentView.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, UIScreen_W, kAlbumCellH);
        
        
        //        //右箭头
        //        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"com_arrow_r"]];
        //        pointY = (CGRectGetHeight(self.frame) - kRightArrowHeight)/2;
        //        pointX = UIScreen_W - kOffsetX - kRightArrowWidth;
        //        _arrowImageView.frame = CGRectMake(pointX, pointY, kRightArrowWidth, kRightArrowHeight);
        //        [self.contentView addSubview:_arrowImageView];
        
        
//        CGFloat pointH = GetPointWith(0.5);
//        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - pointH, UIScreen_W, pointH)];
//        [_lineView setBackgroundColor:[UIColor jrColorWithHex:kLineColor]];
//        [self.contentView addSubview:_lineView];
        //        _lineView.hidden = YES;
    }
    return self;
}


- (void)setModel:(UIAlbumModel *)model {
    _model = model;
    
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.name attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%zd)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLable.attributedText = nameString;
    [[UIImageManager manager] getPostImageWithAlbumModel:model completion:^(UIImage *postImage) {
        self.posterImageView.image = postImage;
    }];
    if (model.selectedCount) {
        self.selectedCountButton.hidden = NO;
        [self.selectedCountButton setTitle:[NSString stringWithFormat:@"%zd",model.selectedCount] forState:UIControlStateNormal];
    } else {
        self.selectedCountButton.hidden = YES;
    }
}

/// For fitting iOS6
- (void)layoutSubviews {
    if (iOS7Later) [super layoutSubviews];
    _selectedCountButton.frame = CGRectMake(self.tz_width - 24 - 30, (kAlbumCellH - 24)/2, 24, 24);
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    if (iOS7Later) [super layoutSublayersOfLayer:layer];
}

#pragma mark - Lazy load

- (UIImageView *)posterImageView {
    
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.frame = CGRectMake(0, 0, kAlbumCellH, kAlbumCellH);
        [self.contentView addSubview:posterImageView];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UILabel *)titleLable {
    if (_titleLable == nil) {
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.font = [UIFont boldSystemFontOfSize:17];
        CGFloat pointY = (CGRectGetHeight(self.frame) - 20.f)/2.f;
        titleLable.frame = CGRectMake(80, pointY, self.tz_width - 80 - 50, 20);
        titleLable.font = [UIFont systemFontOfSize:14.f];
        titleLable.textColor = [UIColor jrColorWithHex:@"#666666"];
        [titleLable setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:titleLable];
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        UIImageView *arrowImageView = [[UIImageView alloc] init];
        CGFloat arrowWH = 15;
        arrowImageView.frame = CGRectMake(self.tz_width - arrowWH - 12, 28, arrowWH, arrowWH);
        [arrowImageView setImage:[UIImage imageNamedFromMyBundle:@"TableViewArrow.png"]];
        [self.contentView addSubview:arrowImageView];
        _arrowImageView = arrowImageView;
    }
    return _arrowImageView;
}

- (UIButton *)selectedCountButton {
    if (_selectedCountButton == nil) {
        UIButton *selectedCountButton = [[UIButton alloc] init];
        selectedCountButton.layer.cornerRadius = 12;
        selectedCountButton.clipsToBounds = YES;
        selectedCountButton.backgroundColor = [UIColor redColor];
        [selectedCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedCountButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:selectedCountButton];
        _selectedCountButton = selectedCountButton;
    }
    return _selectedCountButton;
}

@end






