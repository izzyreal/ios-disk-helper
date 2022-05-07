#import "Disk.h"

@implementation DiskInternalHelpers
+(NSString*) removeSlashesAtBeginning :(NSString*) str {
  NSString* string = [str copy];
  if ([string hasPrefix:@"/"]) {
    string = [string substringFromIndex:1];
  }
  if ([string hasPrefix:@"/"]) {
    string = [DiskInternalHelpers removeSlashesAtBeginning:string];
  }
  return string;
}

+(NSString*) getValidFilePath :(NSString*) originalString {
  NSMutableCharacterSet* invalidCharacters = [NSMutableCharacterSet characterSetWithCharactersInString:@":"];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet newlineCharacterSet]];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
  [invalidCharacters formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
  
  NSString* pathWithoutIllegalCharacters = [[originalString componentsSeparatedByCharactersInSet:invalidCharacters] componentsJoinedByString:@""];
  
  NSString* validFileName = [DiskInternalHelpers removeSlashesAtBeginning:pathWithoutIllegalCharacters];
  
  if (validFileName.length == 0 || [validFileName isEqualToString:@"."])
    [NSException raise:@"Invalid file name provided" format:@"%@ is an invalid file name",
     originalString];
  
  return validFileName;
}

+(NSURL*)createURL:(NSString*)path :(Directory*)directory {
  NSString* filePrefix = @"file://";
  NSString* validPath = nil;
  
  if (path != nil) {
    @try {
      validPath = [self getValidFilePath :path];
    } @catch (NSException* e) {
      @throw e;
    }
  }
  
  NSSearchPathDirectory searchPathDirectory;
  
  switch (directory->directoryType) {
    case DirectoryTypeDocuments: searchPathDirectory = NSDocumentDirectory; break;
    case DirectoryTypeCaches: searchPathDirectory = NSCachesDirectory; break;
    case DirectoryTypeApplicationSupport: searchPathDirectory = NSApplicationSupportDirectory; break;
      
    case DirectoryTypeTemporary: {
      NSString* tempDir = NSTemporaryDirectory();
      
      if (tempDir == nil)
        [NSException raise:@"Could not create temp dir" format:@"Could not create URL for %@",
         [directory pathDescription]];
      
      NSURL* url = [NSURL URLWithString:tempDir];
      
      if (validPath != nil) {
        url = [url URLByAppendingPathComponent:validPath isDirectory:false];
      }
      
      if (![url.absoluteString hasPrefix:filePrefix]) {
        NSString* fixedUrlString = [filePrefix stringByAppendingString:(url.absoluteString)];
        url = [NSURL URLWithString:fixedUrlString];
      }
      
      return url;
    }
      
    case DirectoryTypeSharedContainer: {
      NSURL* url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:(directory->appGroupName)];
      
      if (url == nil)
        [NSException raise:@"Could not create shared container dir" format:@"Could not create URL for %@, check the appGroupName",
         [directory pathDescription]];
      
      if (validPath != nil) {
        url = [url URLByAppendingPathComponent:validPath isDirectory:false];
      }
      
      if (![url.absoluteString hasPrefix:filePrefix]) {
        NSString* fixedUrlString = [filePrefix stringByAppendingString:(url.absoluteString)];
        url = [NSURL URLWithString:fixedUrlString];
      }
      
      return url;
    }
  }
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSURL* url = [fileManager URLsForDirectory:searchPathDirectory inDomains:NSAllDomainsMask].firstObject;
  
  if (url != nil) {
    if (validPath != nil) {
      url = [url URLByAppendingPathComponent:validPath isDirectory:false];
    }
    
    if (![url.absoluteString hasPrefix:filePrefix]) {
      NSString* fixedUrlString = [filePrefix stringByAppendingString:(url.absoluteString)];
      url = [NSURL URLWithString:fixedUrlString];
    }
  } else {
    [NSException raise:@"Could not create URL" format:@"Could not create URL for %@", path];
  }
  
  return url;
}

+(NSURL*)getExistingFileURL:(NSString*)path :(Directory*)directory {
  NSURL* url = [self createURL:path :directory];
  if ([[NSFileManager defaultManager] fileExistsAtPath:url.path])
    return url;
  [NSException raise:@"Could not find an existing file or folder" format:@"Could not find an existing file or folder at %@", url.path];
  return nil;
}

+(void) createSubfoldersBeforeCreatingFile :(NSURL*) url {
  NSURL* subfolderUrl = [url URLByDeletingLastPathComponent];
  bool subfolderExists = false;
  bool isDirectory = false;
  
  NSFileManager* fileManager = [NSFileManager defaultManager];
  
  if ([fileManager fileExistsAtPath:subfolderUrl.path isDirectory:&isDirectory]) {
    if (isDirectory) subfolderExists = true;
  }
  
  if (!subfolderExists) {
    @try {
      [fileManager createDirectoryAtURL:subfolderUrl withIntermediateDirectories:true attributes:nil error:nil];
    } @catch (NSException* e) {
      @throw e;
    }
  }
}

@end
