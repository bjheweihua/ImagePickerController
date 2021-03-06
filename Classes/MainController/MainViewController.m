//
//  MainViewController.m
//  ImagePickerController
//
//  Created by heweihua on 2017/1/13.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "MainViewController.h"
#import "UIImagePickerNaviController.h"
#import "UIView+Layout.h"
#import "UITestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "UIGridViewFlowLayout.h"
#import "UIImageManager.h"
#import "UIVideoPlayerController.h"
#import "UIPhotoPreviewController.h"
#import "UIGifPhotoPreviewController.h"
#import "UIColor+Additions.h"
#import "UIAlbumModel.h"


#define kOffsetX (16.f)
// Screen Size
#define UIScreen_W CGRectGetWidth([[UIScreen mainScreen] bounds])
#define UIScreen_H CGRectGetHeight([[UIScreen mainScreen] bounds])




@interface MainViewController ()
<
UIImagePickerNaviControllerDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate
> {
    
    NSMutableArray *_selectedPhotos;
    NSMutableArray *_selectedAssets;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic, strong) UICollectionView *collectionView;
// 6个设置开关
@property (strong, nonatomic) UISwitch *showTakePhotoBtnSwitch;  ///< 在内部显示拍照按钮
@property (strong, nonatomic) UISwitch *sortAscendingSwitch;     ///< 照片排列按修改时间升序
@property (strong, nonatomic) UISwitch *allowPickingVideoSwitch; ///< 允许选择视频
@property (strong, nonatomic) UISwitch *allowPickingImageSwitch; ///< 允许选择图片
@property (strong, nonatomic) UISwitch *allowPickingGifSwitch;
@property (strong, nonatomic) UISwitch *allowPickingOriginalPhotoSwitch; ///< 允许选择原图
@property (strong, nonatomic) UISwitch *showSheetSwitch; ///< 显示一个sheet,把拍照按钮放在外面
@property (strong, nonatomic) UITextField *maxCountTF;  ///< 照片最大可选张数，设置为1即为单选模式
@property (strong, nonatomic) UITextField *columnNumberTF;
@property (strong, nonatomic) UISwitch *allowCropSwitch;
@property (strong, nonatomic) UISwitch *needCircleCropSwitch;
@end

@implementation MainViewController

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerNaviController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerNaviController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initChildrenView];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    [self configCollectionView];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

-(void) initChildrenView {
    
    // -------------------------1-------------------------
    CGFloat pointY = 20;
    CGRect rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:rect];
    titleLabel.font = [UIFont systemFontOfSize:16];
    [titleLabel setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel];
    [titleLabel setText:@"显示内部拍照按钮"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _showTakePhotoBtnSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_showTakePhotoBtnSwitch addTarget:self action:@selector(showTakePhotoBtnSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _showTakePhotoBtnSwitch.on = YES;
    [self.view addSubview:_showTakePhotoBtnSwitch];
    
    // -------------------------2-------------------------
    pointY = CGRectGetMaxY(titleLabel.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel2 = [[UILabel alloc] initWithFrame:rect];
    titleLabel2.font = [UIFont systemFontOfSize:16];
    [titleLabel2 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel2];
    [titleLabel2 setText:@"拍照按修改时间升序排列"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _sortAscendingSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_sortAscendingSwitch addTarget:self action:@selector(setSortAscendingSwitch:) forControlEvents:UIControlEventValueChanged];
    _sortAscendingSwitch.on = YES;
    [self.view addSubview:_sortAscendingSwitch];

    
    // -------------------------3-------------------------
    pointY = CGRectGetMaxY(titleLabel2.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel3 = [[UILabel alloc] initWithFrame:rect];
    titleLabel3.font = [UIFont systemFontOfSize:16];
    [titleLabel3 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel3];
    [titleLabel3 setText:@"允许选择视频"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _allowPickingVideoSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_allowPickingVideoSwitch addTarget:self action:@selector(allowPickingVideoSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _allowPickingVideoSwitch.on = YES;
    [self.view addSubview:_allowPickingVideoSwitch];
    
    
    
    // -------------------------4-------------------------
    pointY = CGRectGetMaxY(titleLabel3.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel4 = [[UILabel alloc] initWithFrame:rect];
    titleLabel4.font = [UIFont systemFontOfSize:16];
    [titleLabel4 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel4];
    [titleLabel4 setText:@"允许选择照片"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _allowPickingImageSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_allowPickingImageSwitch addTarget:self action:@selector(allowPickingImageSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _allowPickingImageSwitch.on = YES;
    [self.view addSubview:_allowPickingImageSwitch];
    
    // -------------------------5-------------------------
    pointY = CGRectGetMaxY(titleLabel4.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel5 = [[UILabel alloc] initWithFrame:rect];
    titleLabel5.font = [UIFont systemFontOfSize:16];
    [titleLabel5 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel5];
    [titleLabel5 setText:@"允许选择gif照片"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _allowPickingGifSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_allowPickingGifSwitch addTarget:self action:@selector(allowPickingGifSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _allowPickingGifSwitch.on = NO;
    [self.view addSubview:_allowPickingGifSwitch];
    
    // -------------------------6-------------------------
    pointY = CGRectGetMaxY(titleLabel5.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel6 = [[UILabel alloc] initWithFrame:rect];
    titleLabel6.font = [UIFont systemFontOfSize:16];
    [titleLabel6 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel6];
    [titleLabel6 setText:@"允许选择照片原图"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _allowPickingOriginalPhotoSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_allowPickingOriginalPhotoSwitch addTarget:self action:@selector(allowPickingOriginPhotoSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _allowPickingOriginalPhotoSwitch.on = YES;
    [self.view addSubview:_allowPickingOriginalPhotoSwitch];
    
    
    // -------------------------7-------------------------
    pointY = CGRectGetMaxY(titleLabel6.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel7 = [[UILabel alloc] initWithFrame:rect];
    titleLabel7.font = [UIFont systemFontOfSize:16];
    [titleLabel7 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel7];
    [titleLabel7 setText:@"把照片按钮放在外面"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _showSheetSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_showSheetSwitch addTarget:self action:@selector(showSheetSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _showSheetSwitch.on = NO;
    [self.view addSubview:_showSheetSwitch];
    
    // -------------------------8-------------------------
    pointY = CGRectGetMaxY(titleLabel7.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel8 = [[UILabel alloc] initWithFrame:rect];
    titleLabel8.font = [UIFont systemFontOfSize:16];
    [titleLabel8 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel8];
    [titleLabel8 setText:@"照片最大可选张数"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _maxCountTF = [[UITextField alloc] initWithFrame:rect];
    //
    _maxCountTF.clearButtonMode = UITextFieldViewModeWhileEditing;//编辑时会出现个修改X
    _maxCountTF.returnKeyType = UIReturnKeyDone;
    _maxCountTF.keyboardType = UIKeyboardTypeDefault;//UIKeyboardTypeNumberPad;//UIKeyboardTypePhonePad;//UIKeyboardTypeNumbersAndPunctuation;
    _maxCountTF.enablesReturnKeyAutomatically = YES;
    _maxCountTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _maxCountTF.autocorrectionType = UITextAutocorrectionTypeNo;
    _maxCountTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直居中
    _maxCountTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _maxCountTF.delegate = self;
    _maxCountTF.secureTextEntry = NO;
    _maxCountTF.adjustsFontSizeToFitWidth = YES;
    [self.view  addSubview:_maxCountTF];
    [_maxCountTF setDelegate:self];
    _maxCountTF.text = @"9";
    _maxCountTF.borderStyle = UITextBorderStyleRoundedRect;
    
    
    // -------------------------9-------------------------
    pointY = CGRectGetMaxY(titleLabel8.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel9 = [[UILabel alloc] initWithFrame:rect];
    titleLabel9.font = [UIFont systemFontOfSize:16];
    [titleLabel9 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel9];
    [titleLabel9 setText:@"每行展示照片张数"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _columnNumberTF = [[UITextField alloc] initWithFrame:rect];
    _columnNumberTF.clearButtonMode = UITextFieldViewModeWhileEditing;//编辑时会出现个修改X
    _columnNumberTF.returnKeyType = UIReturnKeyDone;
    _columnNumberTF.keyboardType = UIKeyboardTypeDefault;//UIKeyboardTypeNumberPad;//UIKeyboardTypePhonePad;//UIKeyboardTypeNumbersAndPunctuation;
    _columnNumberTF.enablesReturnKeyAutomatically = YES;
    _columnNumberTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _columnNumberTF.autocorrectionType = UITextAutocorrectionTypeNo;
    _columnNumberTF.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直居中
    _columnNumberTF.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _columnNumberTF.delegate = self;
    _columnNumberTF.secureTextEntry = NO;
    _columnNumberTF.adjustsFontSizeToFitWidth = YES;
    [self.view  addSubview:_columnNumberTF];
    [_columnNumberTF setDelegate:self];
    _columnNumberTF.borderStyle = UITextBorderStyleRoundedRect;
    _columnNumberTF.text = @"4";

    
    
    // -------------------------10-------------------------
    pointY = CGRectGetMaxY(titleLabel9.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel10 = [[UILabel alloc] initWithFrame:rect];
    titleLabel10.font = [UIFont systemFontOfSize:16];
    [titleLabel10 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel10];
    [titleLabel10 setText:@"单项模式下允许裁剪"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _allowCropSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_allowCropSwitch addTarget:self action:@selector(allowCropSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _allowCropSwitch.on = NO;
    [self.view addSubview:_allowCropSwitch];
    
    // -------------------------11-------------------------
    pointY = CGRectGetMaxY(titleLabel10.frame) + 2.f;
    rect = CGRectMake(kOffsetX, pointY, UIScreen_W/2 - kOffsetX*2, 30.f);
    UILabel* titleLabel11 = [[UILabel alloc] initWithFrame:rect];
    titleLabel11.font = [UIFont systemFontOfSize:16];
    [titleLabel11 setTextAlignment:NSTextAlignmentRight];
    [self.view addSubview:titleLabel11];
    [titleLabel11 setText:@"使用圆形裁剪框"];
    
    rect = CGRectMake(UIScreen_W/2, pointY, 50, 30);
    _needCircleCropSwitch = [[UISwitch alloc] initWithFrame:rect];
    [_needCircleCropSwitch addTarget:self action:@selector(needCircleCropSwitchClick:) forControlEvents:UIControlEventValueChanged];
    _needCircleCropSwitch.on = NO;
    [self.view addSubview:_needCircleCropSwitch];
}

- (void)configCollectionView {
    // 如不需要长按排序效果，将UIGridViewFlowLayout.h类改成UICollectionViewFlowLayout即可
    UIGridViewFlowLayout *layout = [[UIGridViewFlowLayout alloc] init];
    _margin = 4;
    _itemWH = (self.view.tz_width - 2 * _margin - 4) / 3 - _margin;
    layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    layout.minimumInteritemSpacing = _margin;
    layout.minimumLineSpacing = _margin;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 409, self.view.tz_width, self.view.tz_height - 409) collectionViewLayout:layout];
    CGFloat rgb = 244 / 255.0;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UITestCell class] forCellWithReuseIdentifier:@"UITestCell"];
}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UITestCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UITestCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"AlbumAddBtn.png"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    if (!self.allowPickingGifSwitch.isOn) {
        cell.gifLable.hidden = YES;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == _selectedPhotos.count) {
        
        BOOL showSheet = self.showSheetSwitch.isOn;
        if (showSheet) {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
            [sheet showInView:self.view];
        } else {
            [self pushImagePickerController];
        }
    } else { // preview photos or video / 预览照片或者视频
        
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if ([[asset valueForKey:@"filename"] containsString:@"GIF"] && self.allowPickingGifSwitch.isOn) {
            
            UIGifPhotoPreviewController *vc = [[UIGifPhotoPreviewController alloc] init];
            UIAssetModel *model = [UIAssetModel modelWithAsset:asset type:UIAssetModelMediaTypePhotoGif timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else if (isVideo) { // perview video / 预览视频
            
            UIVideoPlayerController *vc = [[UIVideoPlayerController alloc] init];
            UIAssetModel *model = [UIAssetModel modelWithAsset:asset type:UIAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else { // preview photos / 预览照片
            
            UIImagePickerNaviController *imagePickerVc = [[UIImagePickerNaviController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.maxImagesCount = self.maxCountTF.text.integerValue;
            imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }
}

#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}

#pragma mark - UIImagePickerNaviController

- (void)pushImagePickerController {
    
    if (self.maxCountTF.text.integerValue <= 0) {
        return;
    }
    UIImagePickerNaviController *imagePickerVc = [[UIImagePickerNaviController alloc] initWithMaxImagesCount:self.maxCountTF.text.integerValue columnNumber:self.columnNumberTF.text.integerValue delegate:self pushPhotoPickerVc:YES];
    
    
#pragma mark - 四类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (self.maxCountTF.text.integerValue > 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = self.showTakePhotoBtnSwitch.isOn; // 在内部显示拍照按钮
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // 在这里设置imagePickerVc的外观
    imagePickerVc.navigationBar.translucent = YES;
    imagePickerVc.navigationBar.tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    imagePickerVc.oKButtonTitleColorDisabled = [UIColor jrColorWithHex:@"#cccccc"];
    imagePickerVc.oKButtonTitleColorNormal = [UIColor jrColorWithHex:@"#508cee"];
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = self.allowPickingVideoSwitch.isOn;
    imagePickerVc.allowPickingImage = self.allowPickingImageSwitch.isOn;
    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhotoSwitch.isOn;
    imagePickerVc.allowPickingGif = self.allowPickingGifSwitch.isOn;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = self.allowCropSwitch.isOn;
    imagePickerVc.needCircleCrop = self.needCircleCropSwitch.isOn;
    imagePickerVc.circleCropRadius = 100;
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerNaviController

- (void)takePhoto {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
        // 拍照之前还需要检查相册权限
    } else if ([[UIImageManager manager] authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([[UIImageManager manager] authorizationStatus] == 0) { // 正在弹框询问用户是否允许访问相册，监听权限状态
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            return [self takePhoto];
        });
    } else { // 调用相机
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerVc.sourceType = sourceType;
            if(iOS8Later) {
                _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            [self presentViewController:_imagePickerVc animated:YES completion:nil];
        } else {
            NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        }
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImagePickerNaviController *tzImagePickerVc = [[UIImagePickerNaviController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = self.sortAscendingSwitch.isOn;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        // save photo and get asset / 保存图片，获取到asset
        [[UIImageManager manager] savePhotoWithImage:image completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[UIImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(UIAlbumModel *model) {
                    [[UIImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<UIAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        UIAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        if (self.allowCropSwitch.isOn) { // 允许裁剪,去裁剪
                            UIImagePickerNaviController *imagePicker = [[UIImagePickerNaviController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
                                [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                            }];
                            imagePicker.needCircleCrop = self.needCircleCropSwitch.isOn;
                            imagePicker.circleCropRadius = 100;
                            [self presentViewController:imagePicker animated:YES completion:nil];
                        } else {
                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                        }
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerNaviController *)picker {
    if ([picker isKindOfClass:[UIImagePickerNaviController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - UIImagePickerNaviControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(UIImagePickerNaviController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[UIImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[UIImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(UIImagePickerNaviController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(UIImagePickerNaviController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    // [[UIImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(UIImagePickerNaviController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [_collectionView reloadData];
}

#pragma mark - Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_selectedPhotos removeObjectAtIndex:sender.tag];
    [_selectedAssets removeObjectAtIndex:sender.tag];
    
    [_collectionView performBatchUpdates:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
        [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

- (IBAction)showTakePhotoBtnSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        [_showSheetSwitch setOn:NO animated:YES];
        [_allowPickingImageSwitch setOn:YES animated:YES];
    }
}

- (IBAction)showSheetSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        [_showTakePhotoBtnSwitch setOn:NO animated:YES];
        [_allowPickingImageSwitch setOn:YES animated:YES];
    }
}

- (IBAction)allowPickingOriginPhotoSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        [_allowPickingImageSwitch setOn:YES animated:YES];
        [self.needCircleCropSwitch setOn:NO animated:YES];
        [self.allowCropSwitch setOn:NO animated:YES];
    }
}

- (IBAction)allowPickingImageSwitchClick:(UISwitch *)sender {
    if (!sender.isOn) {
        [_allowPickingOriginalPhotoSwitch setOn:NO animated:YES];
        [_showTakePhotoBtnSwitch setOn:NO animated:YES];
        [_allowPickingVideoSwitch setOn:YES animated:YES];
        [_allowPickingGifSwitch setOn:NO animated:YES];
    }
}

- (IBAction)allowPickingGifSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        [_allowPickingImageSwitch setOn:YES animated:YES];
    }
}

- (IBAction)allowPickingVideoSwitchClick:(UISwitch *)sender {
    if (!sender.isOn) {
        [_allowPickingImageSwitch setOn:YES animated:YES];
    }
}

- (IBAction)allowCropSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        self.maxCountTF.text = @"1";
        [self.allowPickingOriginalPhotoSwitch setOn:NO animated:YES];
    } else {
        [self.needCircleCropSwitch setOn:NO animated:YES];
    }
}

- (IBAction)needCircleCropSwitchClick:(UISwitch *)sender {
    if (sender.isOn) {
        [self.allowCropSwitch setOn:YES animated:YES];
        self.maxCountTF.text = @"1";
        [self.allowPickingOriginalPhotoSwitch setOn:NO animated:YES];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}
#pragma clang diagnostic pop

@end

