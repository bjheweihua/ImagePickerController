//
//  UIAlbumPickerController.m
//  ImagePickerController
//
//  Created by heweihua on 2017/1/17.
//  Copyright © 2017年 heweihua. All rights reserved.
//

#import "UIAlbumPickerController.h"
#import "UIImagePickerNaviController.h"
#import "UIPhotoPickerController.h"
#import "UIImageManager.h"
#import "UIAssetCell.h"
#import "UIAlbumModel.h"
#import "UIAlbumCell.h"
#import "UIView+Layout.h"
#import "UIColor+Additions.h"

@interface UIAlbumPickerController ()<UITableViewDataSource,UITableViewDelegate> {
    
    UITableView *_tableView;
}
@property (nonatomic, strong) NSMutableArray *albumArr;
@end

@implementation UIAlbumPickerController

//- (void)viewDidLoad {
//    
//    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Photos"];
//    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:imagePickerVc.cancelBtnTitleStr style:UIBarButtonItemStylePlain target:imagePickerVc action:@selector(cancelButtonClick)];
//    [self configTableView];
//    // 1.6.10 采用微信的方式，只在相册列表页定义backBarButtonItem为返回，其余的顺系统的做法
//    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSBundle tz_localizedStringForKey:@"Back"] style:UIBarButtonItemStylePlain target:nil action:nil];
//}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initNavibar];
    [self initTableView];
}

-(void) initNavibar{
    
    // titleView
    CGFloat pointW = CGRectGetWidth(self.view.frame) - 16*2;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pointW, 44)];
    titleLabel.font = [UIFont systemFontOfSize:17.f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor jrColorWithHex:@"#666666"];
    self.navigationItem.titleView = titleLabel;
//    [titleLabel setText:@"照片"];
//    [NSBundle tz_localizedStringForKey:@"Photos"];
    
    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
    if (imagePickerVc.allowTakePicture) {
        self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Photos"];
    } else if (imagePickerVc.allowPickingVideo) {
        self.navigationItem.title = [NSBundle tz_localizedStringForKey:@"Videos"];
    }
    
    // rightItem
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancel)];
    UIFont* font = [UIFont systemFontOfSize:14.f];
    UIColor* color = [UIColor jrColorWithHex:@"#666666"];
    NSDictionary* dic = [[NSDictionary alloc]initWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName,nil];
    [rightItem setTitleTextAttributes:dic forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void) initTableView {
    
    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
    [[UIImageManager manager] getAllAlbums:imagePickerVc.allowPickingVideo allowPickingImage:imagePickerVc.allowPickingImage completion:^(NSArray<UIAlbumModel *> *models) {
        _albumArr = [NSMutableArray arrayWithArray:models];
        for (UIAlbumModel *albumModel in _albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        if (!_tableView) {
            //            CGFloat top = 44;
            //            top += 20;
            CGFloat top = 0; // heweihua test
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.tz_width, self.view.tz_height - top) style:UITableViewStylePlain];
            _tableView.rowHeight = 70;
            _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64.f)];
            _tableView.tableFooterView = [[UIView alloc] init];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_tableView registerClass:[UIAlbumCell class] forCellReuseIdentifier:@"UIAlbumCell"];
            [self.view addSubview:_tableView];
        } else {
            [_tableView reloadData];
        }
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
    [imagePickerVc hideProgressHUD];
    if (_albumArr) {
        for (UIAlbumModel *albumModel in _albumArr) {
            albumModel.selectedModels = imagePickerVc.selectedModels;
        }
        [_tableView reloadData];
    } else {
        [self initTableView];
    }
}




#pragma mark - UITableViewDataSource && Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _albumArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UIAlbumCell"];
    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
    cell.selectedCountButton.backgroundColor = imagePickerVc.oKButtonTitleColorNormal;
    cell.model = _albumArr[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIPhotoPickerController *photoPickerVc = [[UIPhotoPickerController alloc] init];
    photoPickerVc.columnNumber = self.columnNumber;
    UIAlbumModel *model = _albumArr[indexPath.row];
    photoPickerVc.model = model;
    __weak typeof(self) weakSelf = self;
    [photoPickerVc setBackButtonClickHandle:^(UIAlbumModel *model) {
        [weakSelf.albumArr replaceObjectAtIndex:indexPath.row withObject:model];
    }];
    [self.navigationController pushViewController:photoPickerVc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Click Event

- (void)cancel {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
    if (imagePickerVc) {
        [imagePickerVc cancelButtonClick];
    }
}


//- (void)cancel {
//    
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    UIImagePickerNaviController *imagePickerVc = (UIImagePickerNaviController *)self.navigationController;
//    if ([imagePickerVc.pickerDelegate respondsToSelector:@selector(imagePickerControllerDidCancel:)]) {
//        [imagePickerVc.pickerDelegate imagePickerControllerDidCancel:imagePickerVc];
//    }
//    if (imagePickerVc.imagePickerControllerDidCancelHandle) {
//        imagePickerVc.imagePickerControllerDidCancelHandle();
//    }
//}



@end






