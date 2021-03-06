//
//  FileListFileCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14/10/29.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kFileListFileCell_IconWidth 45.0
#define kFileListFileCell_LeftPading (kPaddingLeftWidth +kFileListFileCell_IconWidth +20.0)
#define kFileListFileCell_TopPading 10.0

#import "FileListFileCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFURLSessionManager.h"
#import "Coding_FileManager.h"
#import "ASProgressPopUpView.h"


typedef NS_ENUM(NSInteger, DownloadState){
    DownloadStateDownload = 0,
    DownloadStatePause,
    DownloadStateGoon,
    DownloadStateLook
};

@interface FileListFileCell ()<ASProgressPopUpViewDelegate>
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel, *infoLabel, *sizeLabel;
@property (strong, nonatomic) ASProgressPopUpView *progressView;
@property (strong, nonatomic) UIButton *stateButton;
@property (strong, nonatomic) NSProgress *progress;
@end

@implementation FileListFileCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        if (!_iconView) {
            _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([FileListFileCell cellHeight] - kFileListFileCell_IconWidth)/2, kFileListFileCell_IconWidth, kFileListFileCell_IconWidth)];
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.cornerRadius = 2.0;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = [UIColor colorWithHexString:@"0xdddddd"].CGColor;
            [self.contentView addSubview:_iconView];
        }
        if (!_nameLabel) {
            _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, kFileListFileCell_TopPading, (kScreen_Width - kFileListFileCell_LeftPading - 60), 25)];
            _nameLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _nameLabel.font = [UIFont systemFontOfSize:16];
            [self.contentView addSubview:_nameLabel];
        }
        if (!_sizeLabel) {
            _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, ([FileListFileCell cellHeight]- 15)/2+3, (kScreen_Width - kFileListFileCell_LeftPading - 60), 15)];
            _sizeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _sizeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_sizeLabel];
        }
        if (!_infoLabel) {
            _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(kFileListFileCell_LeftPading, ([FileListFileCell cellHeight]- 15 - kFileListFileCell_TopPading), (kScreen_Width - kFileListFileCell_LeftPading - 60), 15)];
            _infoLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _infoLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_infoLabel];
        }
        if (!_progressView) {
            _progressView = [[ASProgressPopUpView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, [FileListFileCell cellHeight]-2.5, kScreen_Width- kPaddingLeftWidth, 2.0)];

            _progressView.popUpViewCornerRadius = 12.0;
            _progressView.delegate = self;
            _progressView.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
            [_progressView setTrackTintColor:[UIColor colorWithHexString:@"0xe6e6e6"]];
            _progressView.popUpViewAnimatedColors = @[[UIColor colorWithHexString:@"0x3bbd79"]];
            _progressView.hidden = YES;
            [self.contentView addSubview:self.progressView];
        }
        if (!_stateButton) {
            _stateButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreen_Width - 55), ([FileListFileCell cellHeight] - 25)/2, 45, 25)];
            [_stateButton addTarget:self action:@selector(clickedByUser) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_stateButton];
        }
    }
    return self;
}
- (void)setProgress:(NSProgress *)progress{
    if (_progress) {
        [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
    }
    _progress = progress;
    if (_progress) {
        [_progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
    }
}
- (void)dealloc{
    if (_progress) {
        [_progress removeObserver:self forKeyPath:@"fractionCompleted"];
    }
    _progress = nil;
}
- (void)changeToState:(DownloadState)state{
    NSString *stateImageName;
    switch (state) {
        case DownloadStateDownload:
            stateImageName = @"icon_file_state_download";
            break;
        case DownloadStatePause:
            stateImageName = @"icon_file_state_pause";
            break;
        case DownloadStateGoon:
            stateImageName = @"icon_file_state_goon";
            break;
        case DownloadStateLook:
            stateImageName = @"icon_file_state_look";
            break;
        default:
            stateImageName = @"icon_file_state_download";
            break;
    }
    if (state == DownloadStateLook) {
        [self setBackgroundColor:[UIColor colorWithHexString:@"0xf1fcf6"]];
    }else{
        [self setBackgroundColor:[UIColor clearColor]];
    }
    [_stateButton setImage:[UIImage imageNamed:stateImageName] forState:UIControlStateNormal];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_file) {
        return;
    }
    _nameLabel.text = _file.name;
    _sizeLabel.text = [NSString sizeDisplayWithByte:_file.size.floatValue];
    _infoLabel.text = [NSString stringWithFormat:@"%@ 创建于 %@", _file.owner.name, [_file.created_at stringTimesAgo]];
    if (_file.preview && _file.preview.length > 0) {
        [_iconView sd_setImageWithURL:[NSURL URLWithString:_file.preview]];
    }else{
        [self configIconWithType:_file.fileType];
    }
}
+ (CGFloat)cellHeight{
    return 75.0;
}

- (void)setFile:(ProjectFile *)file{
    _file = file;
    if (!_file) {
        return;
    }
    //下载的东西
    if ([_file hasBeenDownload]) {
        //已下载
        [self changeToState:DownloadStateLook];
    }else{
        Coding_DownloadTask *cTask = [_file cTask];
        if (cTask) {
            self.progress = cTask.progress;
            if (cTask.task.state == NSURLSessionTaskStateRunning) {
                [self changeToState:DownloadStatePause];
            }else{
                [self changeToState:DownloadStateGoon];
            }
        }else{
            [self changeToState:DownloadStateDownload];
        }
        if (_file.size.floatValue/1024/1024 > 5.0) {//大于5M的文件，下载时显示百分比
            [_progressView showPopUpViewAnimated:NO];
        }else{
            [_progressView hidePopUpViewAnimated:NO];
        }
        [self showProgress:cTask.progress belongSelf:YES];
    }
}

- (void)configIconWithType:(NSString *)fileType{
    if (!fileType) {
        fileType = @"";
    }
    fileType = [fileType lowercaseString];
    NSString *iconName;
    //XXX(s)
    if ([fileType hasPrefix:@"doc"]) {
        iconName = @"icon_file_doc";
    }else if ([fileType hasPrefix:@"ppt"]) {
        iconName = @"icon_file_ppt";
    }else if ([fileType hasPrefix:@"pdf"]) {
        iconName = @"icon_file_pdf";
    }else if ([fileType hasPrefix:@"xls"]) {
        iconName = @"icon_file_xls";
    }
    //XXX
    else if ([fileType isEqualToString:@"txt"]) {
        iconName = @"icon_file_txt";
    }else if ([fileType isEqualToString:@"ai"]) {
        iconName = @"icon_file_ai";
    }else if ([fileType isEqualToString:@"apk"]) {
        iconName = @"icon_file_apk";
    }else if ([fileType isEqualToString:@"md"]) {
        iconName = @"icon_file_md";
    }else if ([fileType isEqualToString:@"psd"]) {
        iconName = @"icon_file_psd";
    }
    //XXX||YYY
    else if ([fileType isEqualToString:@"zip"] || [fileType isEqualToString:@"rar"] || [fileType isEqualToString:@"arj"]) {
        iconName = @"icon_file_zip";
    }else if ([fileType isEqualToString:@"html"]
             || [fileType isEqualToString:@"xml"]
             || [fileType isEqualToString:@"java"]
             || [fileType isEqualToString:@"h"]
             || [fileType isEqualToString:@"m"]
             || [fileType isEqualToString:@"cpp"]
             || [fileType isEqualToString:@"json"]
             || [fileType isEqualToString:@"cs"]
             || [fileType isEqualToString:@"go"]) {
        iconName = @"icon_file_code";
    }else if ([fileType isEqualToString:@"avi"]
              || [fileType isEqualToString:@"rmvb"]
              || [fileType isEqualToString:@"rm"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"divx"]
              || [fileType isEqualToString:@"mpeg"]
              || [fileType isEqualToString:@"mpe"]
              || [fileType isEqualToString:@"wmv"]
              || [fileType isEqualToString:@"mp4"]
              || [fileType isEqualToString:@"mkv"]
              || [fileType isEqualToString:@"vob"]) {
        iconName = @"icon_file_movie";
    }else if ([fileType isEqualToString:@"mp3"]
              || [fileType isEqualToString:@"wav"]
              || [fileType isEqualToString:@"mid"]
              || [fileType isEqualToString:@"asf"]
              || [fileType isEqualToString:@"mpg"]
              || [fileType isEqualToString:@"tti"]) {
        iconName = @"icon_file_music";
    }
    //unknown
    else{
        iconName = @"icon_file_unknown";
    }
    _iconView.image = [UIImage imageNamed:iconName];
}
- (void)clickedByUser{
    Coding_FileManager *manager = [Coding_FileManager sharedManager];
    NSURL *fileUrl = [manager diskUrlForFile:_file.diskFileName];
    if (fileUrl) {//已经下载到本地了
        if (_showDiskFileBlock) {
            _showDiskFileBlock(fileUrl, _file);
        }
    }else{//要下载
        NSURLSessionDownloadTask *downloadTask;
        if (_file.cTask) {//暂停或者重新开始
            downloadTask = _file.cTask.task;
            switch (downloadTask.state) {
                case NSURLSessionTaskStateRunning:
                    [downloadTask suspend];
                    [self changeToState:DownloadStateGoon];

                    break;
                case NSURLSessionTaskStateSuspended:
                    [downloadTask resume];
                    [self changeToState:DownloadStatePause];
                    break;
                default:
                    break;
            }
        }else{//新建下载
            __weak typeof(self) weakSelf = self;
            __weak typeof(_file) weakFile = self.file;
            NSURL *downloadURL = [NSURL URLWithString:_file.downloadPath];
            NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
            
            NSProgress *progress;
            NSURLSessionDownloadTask *downloadTask = [manager.af_manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                NSLog(@"destination------Path");
                NSURL *downloadUrl = [[Coding_FileManager sharedManager] urlForDownloadFolder];
                Coding_DownloadTask *cTask = [[Coding_FileManager sharedManager] cTaskForResponse:response];
                if (cTask) {
                    downloadUrl = [downloadUrl URLByAppendingPathComponent:cTask.diskFileName];
                }else{
                    downloadUrl = [downloadUrl URLByAppendingPathComponent:[response suggestedFilename]];
                }
                return downloadUrl;
            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                [progress removeObserver:weakSelf forKeyPath:@"fractionCompleted" context:NULL];
                if (error) {
                    [manager removeCTaskForKey:weakFile.storage_key];
                    [weakSelf changeToState:DownloadStateDownload];
                    [weakSelf showError:error];
                    NSLog(@"ERROR:%@", error.description);
                }else{
                    [manager removeCTaskForResponse:response];
                    [weakSelf changeToState:DownloadStateLook];
                    NSLog(@"File downloaded to: %@", filePath);
                }
            }];
            [downloadTask resume];
            [manager addDownloadTask:downloadTask progress:progress fileName:_file.diskFileName forKey:_file.storage_key];
            self.progress = progress;
            _progressView.progress = 0.0;
            _progressView.hidden = NO;
            [self changeToState:DownloadStatePause];
        }
    }
}
#pragma mark Progress
- (void)showProgress:(NSProgress *)progress belongSelf:(BOOL)belongSelf{
    if (!belongSelf) {
        //移除观察者
//        if (progress) {
//            [progress removeObserver:self forKeyPath:@"fractionCompleted" context:NULL];
//        }
    }else{
        if (!progress) {
            //隐藏进度
            if (self.progressView) {
                self.progressView.hidden = YES;
            }
        }else{
            //更新进度
            NSLog(@"Progress… %f", progress.fractionCompleted);
            self.progressView.progress = progress.fractionCompleted;
            if (ABS(progress.fractionCompleted - 1.0) < 0.0001) {
                //已完成
                [self.progressView hidePopUpViewAnimated:YES];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.progressView.hidden = YES;
                });
            }else{
                self.progressView.hidden = NO;
            }
        }
    }
    
}

#pragma mark ASProgressPopUpView
- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

- (void)progressViewDidHidePopUpView:(ASProgressPopUpView *)progressView{
    progressView.hidden = YES;
}

#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        NSProgress *cellProgress = _file.cTask.progress;
        BOOL belongSelf = NO;
        if (cellProgress && cellProgress == progress) {
            belongSelf = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self && [self isKindOfClass:[FileListFileCell class]] && [self window] != nil) {
                [self showProgress:progress belongSelf:belongSelf];
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
