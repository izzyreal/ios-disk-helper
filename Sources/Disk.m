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

+(void)remove:(NSString*)path :(Directory*)directory {
  @try {
    NSURL* url = [DiskInternalHelpers getExistingFileURL:path :directory];
    NSError* e = nil;
    
    if (![[NSFileManager defaultManager] removeItemAtURL:url error:&e])
      [NSException raise:@"Could not remove specified URL" format:@"Could not remove %@ from %@: %@", path, [directory pathDescription], e.description];
  } @catch (NSException* e) {
    @throw e;
  }
}

+(void)remove:(NSURL*)url {
  @try {
    NSError* e = nil;
    if (![[NSFileManager defaultManager] removeItemAtURL:url error:&e])
      [NSException raise:@"Could not remove specified URL" format:@"Could not remove %@: %@", url.path, e.description];
  } @catch (NSException* e) {
    @throw e;
  }
}

+(void)rename:(NSString*)path :(Directory*)directory :(NSString*)newPath {
  @try {
    NSURL* currentUrl = [DiskInternalHelpers getExistingFileURL:path :directory];
    NSString* justDirectoryPath = [DiskInternalHelpers createURL:nil :directory].absoluteString;
    NSString* currentFilePath = [currentUrl.absoluteString stringByReplacingOccurrencesOfString:justDirectoryPath withString:@""];
    
    if ([self isFolder:currentUrl] && ![currentFilePath hasSuffix:@"/"]) {
      currentFilePath = [currentFilePath stringByAppendingString:@"/"];
    }
    
    NSString* currentValidFilePath = [DiskInternalHelpers getValidFilePath:path];
    NSString* newValidFilePath = [DiskInternalHelpers getValidFilePath:newPath];
    NSString* newFilePath = [currentFilePath stringByReplacingOccurrencesOfString:currentValidFilePath withString:newValidFilePath];
    
    NSURL* newUrl = [DiskInternalHelpers createURL:newFilePath :directory];
    [DiskInternalHelpers createSubfoldersBeforeCreatingFile:newUrl];
    
    NSError* e;
    
    bool success = [[NSFileManager defaultManager] moveItemAtURL:currentUrl toURL:newUrl error:&e];
    
    if (!success) {
      [NSException raise:@"Could not rename file" format:@"Could not rename %@ in %@ to %@: %@", path, [directory pathDescription], newPath, e.description];
    }
  } @catch (NSException* e) {
    @throw e;
  }
}

+(bool)exists:(NSString*)path :(Directory*)directory {
  @try {
    [DiskInternalHelpers getExistingFileURL:path :directory];
    return true;
  } @catch (NSException* e) {
    return false;
  }
  return false;
}

+(bool)exists:(NSURL*)url {
  return [[NSFileManager defaultManager] fileExistsAtPath:url.path];
}

+(bool)isFolder:(NSURL*)url {
  bool isDirectory = false;
  if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory]) {
    if (isDirectory) return true;
  }
  return false;
}

/// Construct URL for a potentially existing or non-existent file. Will not throw if the file does not exist.
///
/// - Parameters:
///   - path: path of file relative to directory (set nil for entire directory)
///   - directory: directory for the specified path
/// - Returns: URL for either an existing or non-existing file
/// - Throws: Error if URL creation failed
+(NSURL*)url:(NSString*)path :(Directory*)directory {
  @try {
    return [DiskInternalHelpers createURL:path :directory];
  } @catch (NSException* e) {
    @throw e;
  }
}

+(NSArray<NSURL*>*)listFiles:(NSURL*)directoryUrl {
  NSError* e;
  
  NSArray<NSURL*>* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:directoryUrl includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&e];
  
  if (contents == nil) {
    [NSException raise:@"Could not list files" format:@"Could not list files in %@: %@", directoryUrl.path, e.description];
  }
  
  return contents;
}

@end
