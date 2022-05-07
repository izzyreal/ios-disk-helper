//
//  objdisk.h
//  objdisk
//
//  Created by Izmar on 07/05/2022.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DirectoryType) {
  DirectoryTypeDocuments,
  DirectoryTypeCaches,
  DirectoryTypeApplicationSupport,
  DirectoryTypeTemporary,
  DirectoryTypeSharedContainer
};

@interface Directory : NSObject {
@public DirectoryType directoryType;
@public NSString* appGroupName;
}

- (id) init:(DirectoryType)directoryType;
- (id) initSharedContainer:(NSString*)appGroupName;
- (NSString*) pathDescription;
- (bool) equals:(Directory*)other;

@end

@interface Disk : NSObject
+(void)save:(NSData*)data :(Directory*)directory :(NSString*)path;
+(NSData*)retrieve:(NSString*)path :(Directory*)directory;
+(void)remove:(NSString*)path :(Directory*)directory;
+(void)remove:(NSURL*)path;
+(bool)exists:(NSString*)path :(Directory*)directory;
+(bool)exists:(NSURL*)url;
+(NSURL*)url:(NSString*)path :(Directory*)directory;
@end

@interface DiskInternalHelpers : NSObject
+(NSString*) getValidFilePath :(NSString*)originalString;
+(NSURL*)createURL:(NSString*)path :(Directory*)directory;
+(NSURL*)getExistingFileURL:(NSString*)path :(Directory*)directory; // throws if not exist
+(void)createSubfoldersBeforeCreatingFile :(NSURL*)url;
+(NSString*)removeSlashesAtBeginning:(NSString*) str;
@end
