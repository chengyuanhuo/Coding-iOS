//
//  ProjectFile.h
//  Coding_iOS
//
//  Created by Ease on 14/11/13.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Coding_FileManager.h"

@interface ProjectFile : NSObject
@property (readwrite, nonatomic, strong) NSDate *created_at, *updated_at;
@property (readwrite, nonatomic, strong) NSNumber *file_id, *owner_id, *parent_id, *type, *current_user_role_id, *size, *project_id;
@property (readwrite, nonatomic, strong) NSString *name, *fileType, *owner_preview, *preview, *storage_key, *storage_type;
@property (readwrite, nonatomic, strong) User *owner;
@property (readwrite, nonatomic, strong) NSString *diskFileName;

- (Coding_DownloadTask *)cTask;
- (NSURL *)hasBeenDownload;
- (NSString *)downloadPath;

- (NSString *)toDeletePath;
- (NSDictionary *)toDeleteParams;

- (NSDictionary *)toMoveToParams;
@end
