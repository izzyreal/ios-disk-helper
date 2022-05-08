#include "DiskCpp.h"
#include "Disk.h"

void DiskCpp::test() {
  NSString* dataString = @"This is a test";
  NSData* data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
  Directory* dir = [[Directory alloc] init:DirectoryTypeDocuments];
  NSString* path = @"test.txt";
  [Disk save:data :dir :path];
  NSData* retrievedData = [Disk retrieve:path :dir];
  bool isEqual = [retrievedData isEqualToData:data];
  NSString* retrievedDataString = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
  bool isEqual2 = [retrievedDataString isEqual:dataString];
  assert(isEqual && isEqual2);
}
