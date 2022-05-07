//
//  objdisk_tests.m
//  objdisk-tests
//
//  Created by Izmar on 07/05/2022.
//

#import <XCTest/XCTest.h>

#import "Disk.h"

@interface objdisk_tests : XCTestCase
@end

@implementation objdisk_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)testDiskInstantiation {
  Disk* disk = [[Disk alloc] init];
  XCTAssertNotNil(disk);
}

- (void)testDirectoryInstantiation {
  Directory* directory = [[Directory alloc] init];
  XCTAssertNotNil(directory);
}

- (void)testCachesDirectoryInstantiation {
  Directory* directory = [[Directory alloc] init:DirectoryTypeCaches];
  DirectoryType directoryType = directory->directoryType;
  XCTAssertEqual(directoryType, DirectoryTypeCaches);
}

- (void)testSharedContainerDirectoryInstantiation {
  Directory* directory = [[Directory alloc] initSharedContainer:@"foo"];
  DirectoryType directoryType = directory->directoryType;
  XCTAssertEqual(directoryType, DirectoryTypeSharedContainer);
  XCTAssertEqual(directory->appGroupName, @"foo");
}

- (void)testPathDescriptions {
  NSString* description1 = [[[Directory alloc] init:DirectoryTypeDocuments] pathDescription];
  NSString* description2 = [[[Directory alloc] init:DirectoryTypeCaches] pathDescription];
  NSString* description3 = [[[Directory alloc] init:DirectoryTypeApplicationSupport] pathDescription];
  NSString* description4 = [[[Directory alloc] init:DirectoryTypeTemporary] pathDescription];
  NSString* description5 = [[[Directory alloc] initSharedContainer:@"foo"] pathDescription];
  XCTAssertGreaterThan(description1.length, 0);
  XCTAssertGreaterThan(description2.length, 0);
  XCTAssertGreaterThan(description3.length, 0);
  XCTAssertGreaterThan(description4.length, 0);
  XCTAssertGreaterThan(description5.length, 0);
}

- (void)testEqualsPositive {
  Directory* dir1a = [[Directory alloc] init:DirectoryTypeDocuments];
  Directory* dir1b = [[Directory alloc] init:DirectoryTypeDocuments];
  Directory* dir2a = [[Directory alloc] init:DirectoryTypeCaches];
  Directory* dir2b = [[Directory alloc] init:DirectoryTypeCaches];
  Directory* dir3a = [[Directory alloc] init:DirectoryTypeApplicationSupport];
  Directory* dir3b = [[Directory alloc] init:DirectoryTypeApplicationSupport];
  Directory* dir4a = [[Directory alloc] init:DirectoryTypeTemporary];
  Directory* dir4b = [[Directory alloc] init:DirectoryTypeTemporary];
  Directory* dir5a = [[Directory alloc] initSharedContainer:@"foo"];
  Directory* dir5b = [[Directory alloc] initSharedContainer:@"foo"];
  XCTAssertTrue([dir1a equals:dir1b]);
  XCTAssertTrue([dir2a equals:dir2b]);
  XCTAssertTrue([dir3a equals:dir3b]);
  XCTAssertTrue([dir4a equals:dir4b]);
  XCTAssertTrue([dir5a equals:dir5b]);
}

- (void)testEqualsNegative {
  Directory* dir1 = [[Directory alloc] init:DirectoryTypeDocuments];
  Directory* dir2 = [[Directory alloc] init:DirectoryTypeCaches];
  Directory* dir3 = [[Directory alloc] init:DirectoryTypeApplicationSupport];
  Directory* dir4 = [[Directory alloc] init:DirectoryTypeTemporary];
  Directory* dir5a = [[Directory alloc] initSharedContainer:@"foo"];
  Directory* dir5b = [[Directory alloc] initSharedContainer:@"bar"];
  XCTAssertFalse([dir1 equals:dir2]);
  XCTAssertFalse([dir1 equals:dir3]);
  XCTAssertFalse([dir1 equals:dir4]);
  XCTAssertFalse([dir1 equals:dir5a]);
  XCTAssertFalse([dir5a equals:dir5b]);
}

- (void)testCreateDocumentsURL {
  NSURL* url = nil;
  NSString* path = @"i/am/a/path/foo.txt";
  XCTAssertNoThrow(url = [DiskInternalHelpers createURL:path :[[Directory alloc] init:DirectoryTypeDocuments]]);
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSURL* expectedUrl = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSAllDomainsMask].firstObject;
  expectedUrl = [expectedUrl URLByAppendingPathComponent:path];
  XCTAssertTrue([url.absoluteString isEqualToString:expectedUrl.absoluteString]);
}

- (void)testCreateCachesURL {
  NSURL* url = nil;
  NSString* path = @"i/am/a/path/foo.txt";
  XCTAssertNoThrow(url = [DiskInternalHelpers createURL:path :[[Directory alloc] init:DirectoryTypeCaches]]);
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSURL* expectedUrl = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSAllDomainsMask].firstObject;
  expectedUrl = [expectedUrl URLByAppendingPathComponent:path];
  XCTAssertTrue([url.absoluteString isEqualToString:expectedUrl.absoluteString]);
}

- (void)testCreateApplicationSupportURL {
  NSURL* url = nil;
  NSString* path = @"i/am/a/path/foo.txt";
  XCTAssertNoThrow(url = [DiskInternalHelpers createURL:path :[[Directory alloc] init:DirectoryTypeApplicationSupport]]);
  NSFileManager* fileManager = [NSFileManager defaultManager];
  NSURL* expectedUrl = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSAllDomainsMask].firstObject;
  expectedUrl = [expectedUrl URLByAppendingPathComponent:path];
  XCTAssertTrue([url.absoluteString isEqualToString:expectedUrl.absoluteString]);
}

- (void)testCreateTemporaryURL {
  NSURL* url = nil;
  NSString* path = @"i/am/a/path/foo.txt";
  XCTAssertNoThrow(url = [DiskInternalHelpers createURL:path :[[Directory alloc] init:DirectoryTypeTemporary]]);
  NSURL* expectedUrl = [NSURL URLWithString:[@"file://" stringByAppendingString:NSTemporaryDirectory()]];
  expectedUrl = [expectedUrl URLByAppendingPathComponent:path];
  XCTAssertTrue([url.absoluteString isEqualToString:expectedUrl.absoluteString]);
}

- (void)testCreateSharedContainerURL {
  NSURL* url = nil;
  NSString* path = @"i/am/a/path/foo.txt";
  XCTAssertNoThrow(url = [DiskInternalHelpers createURL:path :[[Directory alloc] initSharedContainer:@"test_appgroup"]]);
  NSURL* expectedUrl = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"test_appgroup"];
  expectedUrl = [expectedUrl URLByAppendingPathComponent:path];
  XCTAssertTrue([url.absoluteString isEqualToString:expectedUrl.absoluteString]);
}

- (void)testSaveAndRetrieve {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  [Disk save:data :dir :path];
  NSData* retrievedData = [Disk retrieve:path :dir];
  XCTAssertNotNil(retrievedData);
  XCTAssertTrue([retrievedData isEqualToData:data]);
  NSString* retrievedDataString = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
  XCTAssertTrue([retrievedDataString isEqual:dataString]);
}

- (void)testRemoveByPathAndDir {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  [Disk save:data :dir :path];
  NSURL* url = [DiskInternalHelpers createURL:path :dir];
  assert([[NSFileManager defaultManager] fileExistsAtPath:url.path]);
  [Disk remove:path :dir];
  XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:url.path]);
}

- (void)testRemoveByURL {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  [Disk save:data :dir :path];
  NSURL* url = [DiskInternalHelpers createURL:path :dir];
  assert([[NSFileManager defaultManager] fileExistsAtPath:url.path]);
  [Disk remove:url];
  XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:url.path]);
}

- (void)testExists {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  [Disk save:data :dir :path];
  XCTAssertTrue([Disk exists:path :dir]);
  XCTAssertTrue([Disk exists:[Disk url:path :dir]]);
}

- (void)testIsFolder {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"Folder1/Folder2/test.txt";
  [Disk save:data :dir :path];

  NSString* folderPath = @"Folder1/Folder2";
  NSURL* folder = [Disk url:folderPath :dir];
  
  XCTAssertTrue([Disk isFolder:folder]);
}

- (void)testRename {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"Folder1/Folder2/test.txt";
  [Disk save:data :dir :path];
  NSString* uuid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString* newPath = [@"Folder1/Folder2/" stringByAppendingString:uuid];
  
  XCTAssertNoThrow([Disk rename:path :dir :newPath]);
  XCTAssertTrue([Disk exists:newPath :dir]);
}

- (void)testListFiles {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path1 = @"Folder1/test1.txt";
  NSString* uuid = [[NSProcessInfo processInfo] globallyUniqueString];
  NSString* path2 = [@"Folder1/" stringByAppendingString:uuid];
  [Disk save:data :dir :path1];
  [Disk save:data :dir :path2];
  NSArray<NSURL*>* files = [Disk listFiles:[Disk url:@"Folder1" :dir]];
  XCTAssertGreaterThanOrEqual(files.count, 2);

  NSURL* url1 = [Disk url:path1 :dir];
  NSURL* url2 = [Disk url:path2 :dir];
  
  bool hasUrl1 = false;
  bool hasUrl2 = false;
  
  for (NSURL* url in files) {
    if ([url.path isEqualToString:url1.path]) hasUrl1 = true;
    if ([url.path isEqualToString:url2.path]) hasUrl2 = true;
  }
  
  XCTAssertTrue(hasUrl1 && hasUrl2);
}

- (void)testUrl {
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  XCTAssertNoThrow([Disk url:path :dir]);
}

- (void)testRemoveSlashesAtBeginning {
  NSString* positiveResult1 = [DiskInternalHelpers removeSlashesAtBeginning:@"/foo/bar"];
  XCTAssertTrue([positiveResult1 isEqualToString:@"foo/bar"]);
  NSString* positiveResult2 = [DiskInternalHelpers removeSlashesAtBeginning:@"//foo/bar"];
  XCTAssertTrue([positiveResult2 isEqualToString:@"foo/bar"]);
  NSString* negativeResult = [DiskInternalHelpers removeSlashesAtBeginning:@"foo/bar"];
  XCTAssertTrue([negativeResult isEqualToString:@"foo/bar"]);
}

- (void)testGetValidFilePath {
  NSString* result = [DiskInternalHelpers getValidFilePath:@"not_sure😙++_%5\n\nwhat_/this\t\t'may.be"];
  NSString* expectedResult = @"not_sure😙++_%5what_/this'may.be";
  XCTAssertTrue([result isEqualToString:expectedResult]);
}

- (void)testGetExistingFileURL {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"get_existing_file_url_test.txt";
  
  NSURL* url = [DiskInternalHelpers createURL:path :dir];
  [[NSFileManager defaultManager] removeItemAtPath:url.path error:nil];
  XCTAssertThrows([DiskInternalHelpers getExistingFileURL:path :dir]);
  
  [Disk save:data :dir :path];
  XCTAssertNoThrow([DiskInternalHelpers getExistingFileURL:path :dir]);
}

- (void)testCreateSubfoldersBeforeCreatingFile {
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];

  NSString* expectedExistingFoldersPath = @"Folder1/Folder2/Folder3";
  NSURL* parentFolderUrl = [DiskInternalHelpers createURL:expectedExistingFoldersPath :dir];
  [[NSFileManager defaultManager] removeItemAtPath:parentFolderUrl.path error:nil];

  assert(![[NSFileManager defaultManager] fileExistsAtPath:parentFolderUrl.path]);
  
  NSString* filePath = @"Folder1/Folder2/Folder3/foo.txt";
  NSURL* fileUrl = [DiskInternalHelpers createURL:filePath :dir];
  [DiskInternalHelpers createSubfoldersBeforeCreatingFile:fileUrl];

  XCTAssertNoThrow([DiskInternalHelpers getExistingFileURL:expectedExistingFoldersPath :dir]);
}

@end
