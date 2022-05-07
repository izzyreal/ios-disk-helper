//
//  objdisk.m
//  objdisk
//
//  Created by Izmar on 07/05/2022.
//

#import "Disk.h"

@implementation Directory

- (id)init:(DirectoryType)type {
  if(self = [super init]) {
    directoryType = type;
    NSLog(@"Debug response");
  }
  return self;
}

- (id)initSharedContainer:(NSString*)_appGroupName {
  if(self = [super init]) {
    directoryType = DirectoryTypeSharedContainer;
    appGroupName = _appGroupName;
    NSLog(@"Debug response");
  }
  return self;
}

- (NSString*) pathDescription {
  switch(directoryType) {
    case DirectoryTypeDocuments: return @"<Application_Home>/Documents";
    case DirectoryTypeCaches: return @"<Application_Home>/Library/Caches";
    case DirectoryTypeApplicationSupport: return @"<Application_Home>/Library/Application";
    case DirectoryTypeTemporary: return @"<Application_Home>/tmp";
    case DirectoryTypeSharedContainer: return appGroupName;
  }
}

- (bool) equals:(Directory*)other {
  if (directoryType != other->directoryType) return false;
  
  if (directoryType == DirectoryTypeSharedContainer
      && ![appGroupName isEqualToString:other->appGroupName]) return false;
  
  return true;
}

@end


@implementation Disk

+(void)save:(NSData*)data :(Directory*)directory :(NSString*)path {
  
  if (data == nil || directory == nil || path == nil)
    [NSException raise:@"Could not save data" format:@"Make sure to provide valid data, directory and path", nil];
  
  @try {
    NSURL* url = [DiskInternalHelpers createURL:path :directory];
    [DiskInternalHelpers createSubfoldersBeforeCreatingFile:url];
    [data writeToURL:url atomically:true];
  } @catch (NSException* e) {
    @throw e;
  }
}

+(NSData*)retrieve: (NSString*)path :(Directory*)directory {
  if (path == nil || directory == nil)
    [NSException raise:@"Could not retrieve data" format:@"Make sure to provide valid path and directory", nil];

  NSData* result = nil;

  @try {
    NSURL* url = [DiskInternalHelpers createURL:path :directory];
    result = [[NSData alloc] initWithContentsOfURL:url];
  } @catch (NSException* e) {
    @throw e;
  }

  return result;
}

@end
