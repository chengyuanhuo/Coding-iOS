//
//  FolderToMoveViewController.m
//  Coding_iOS
//
//  Created by Ease on 14/11/27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kCellIdentifier_ProjectFolderList @"ProjectFolderListCell"

#import "FolderToMoveViewController.h"
#import "ProjectFolderListCell.h"
#import "EaseToolBar.h"
#import "SettingTextViewController.h"
#import "Coding_NetAPIManager.h"

@interface FolderToMoveViewController ()<UITableViewDataSource, UITableViewDelegate, EaseToolBarDelegate>
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) EaseToolBar *myToolBar;
@end

@implementation FolderToMoveViewController
- (void)loadView{
    [super loadView];
    if (self.curFolder) {
        self.title = self.curFolder.name;
    }else if (self.curProject){
        self.title = self.curProject.name;
    }else{
        self.title = @"选择目标文件夹";
    }

    
    CGRect frame = [UIView frameWithOutNav];
    self.view = [[UIView alloc] initWithFrame:frame];
    //    添加myTableView
    _myTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [tableView registerClass:[ProjectFolderListCell class] forCellReuseIdentifier:kCellIdentifier_ProjectFolderList];
        [self.view addSubview:tableView];
        tableView;
    });
    //添加底部ToolBar
    EaseToolBarItem *item1 = [EaseToolBarItem easeToolBarItemWithTitle:@" 新建文件夹" image:@"button_file_createFolder_enable" disableImage:@"button_file_createFolder_unable"];
    EaseToolBarItem *item2 = [EaseToolBarItem easeToolBarItemWithTitle:@" 移动到这里" image:@"button_file_move_enable" disableImage:@"button_file_move_unable"];
    item1.enabled = [self canCreatNewFolder];
    item2.enabled = [self canMovedHere];
    
    _myToolBar = [EaseToolBar easeToolBarWithItems:@[item1, item2]];
    [_myToolBar setY:CGRectGetHeight(self.view.frame) - CGRectGetHeight(_myToolBar.frame)];
    _myToolBar.delegate = self;
    [self.view addSubview:_myToolBar];

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0,CGRectGetHeight(_myToolBar.frame), 0.0);
    self.myTableView.contentInset = contentInsets;
    self.myTableView.scrollIndicatorInsets = contentInsets;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
}
- (void)dismissSelf{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark Data Thing
- (NSArray *)dataList{
    if (self.curFolder) {
        return self.curFolder.sub_folders;
    }else{
        return self.rootFolders.list;
    }
}
- (BOOL)canMovedHere{
    return (self.curFolder != nil);
}
- (BOOL)canCreatNewFolder{
    return (self.curFolder == nil || (self.curFolder.parent_id.intValue == 0 && self.curFolder.file_id.intValue != 0));
}

#pragma mark Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row = 0;
    if ([self dataList]) {
        row = [[self dataList] count];
    }
    return row;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectFolderListCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_ProjectFolderList forIndexPath:indexPath];
    cell.useToMove = YES;
    ProjectFolder *folder = [[self dataList] objectAtIndex:indexPath.row];
    cell.folder = folder;
    [tableView addLineforPlainCell:cell forRowAtIndexPath:indexPath withLeftSpace:kPaddingLeftWidth];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ProjectFolderListCell cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ProjectFolder *clickedFolder = [[self dataList] objectAtIndex:indexPath.row];

    FolderToMoveViewController *vc = [[FolderToMoveViewController alloc] init];
    vc.toMovedFile = self.toMovedFile;
    vc.curProject = self.curProject;
    vc.rootFolders = self.rootFolders;
    vc.curFolder = clickedFolder;
    vc.moveToFolderBlock = self.moveToFolderBlock;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma EaseToolBarDelegate
- (void)easeToolBar:(EaseToolBar *)toolBar didClickedIndex:(NSInteger)index{
    switch (index) {
        case 0:
        {//新建文件夹
            NSLog(@"新建文件夹");
            __weak typeof(self) weakSelf = self;
            [SettingTextViewController showSettingFolderNameVCFromVC:self withTitle:@"新建文件夹" textValue:nil type:SettingTypeNewFolderName doneBlock:^(NSString *textValue) {
                NSLog(@"%@", textValue);
                [[Coding_NetAPIManager sharedManager] request_CreatFolder:textValue inFolder:weakSelf.curFolder inProject:weakSelf.curProject andBlock:^(id data, NSError *error) {
                    if (data) {
                        if (weakSelf.curFolder) {
                            [weakSelf.curFolder.sub_folders insertObject:data atIndex:0];
                        }else{
                            [weakSelf.rootFolders.list insertObject:data atIndex:1];
                        }
                        [weakSelf.myTableView reloadData];
                        [weakSelf showHudTipStr:@"创建文件夹成功"];
                    }
                }];
            }];
        }
            break;
        case 1:
        {//移动文件
            NSLog(@"移动文件");
            if (self.moveToFolderBlock) {
                self.moveToFolderBlock(self.curFolder, self.toMovedFile);
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

@end
