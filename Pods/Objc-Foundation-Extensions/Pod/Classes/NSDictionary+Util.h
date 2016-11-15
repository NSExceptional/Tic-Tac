//
//  NSDictionary+Util.h
//  Pods
//
//  Created by Tanner on 2/15/16.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Util)

- (NSString *)JSONString;

/** @return an array of dictionaries containing the pairs in the recieving array.
 @note \c entryLimit must be greater than \c 0. */
- (NSArray<NSDictionary*> *)split:(NSUInteger)entryLimit;

- (NSDictionary *)dictionaryByReplacingValuesForKeys:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryByReplacingKeysWithNewKeys:(NSDictionary *)oldKeysToNewKeys;

- (NSArray *)allKeyPaths;

@end
