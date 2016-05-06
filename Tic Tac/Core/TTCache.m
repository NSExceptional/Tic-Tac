//
//  TTCache.m
//  Tic Tac
//
//  Created by Tanner on 5/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "TTCache.h"


/// Map of {yak id: path}
static NSMutableDictionary *pathsToCommentCaches;
static NSMutableOrderedSet *yaks;
static NSMutableOrderedSet *visitedPostIdentifiers;
static NSString *documentsDirectory;
static NSString *pathToYaks;
static NSString *pathToVisitedPosts;
static NSString *pathToCommentsDirectory;

static NSUInteger const kYakCacheSize = 5000;
static NSUInteger const kVisitedPostsSize = 10000;

@implementation TTCache

+ (void)initialize {
    if (self == [TTCache class]) {
        yaks                    = [NSMutableOrderedSet orderedSet];
        visitedPostIdentifiers  = [NSMutableOrderedSet orderedSet];
        pathsToCommentCaches    = [NSMutableDictionary dictionary];
        documentsDirectory      = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        pathToYaks              = [documentsDirectory stringByAppendingPathComponent:@"YakCache.plist"];
        pathToVisitedPosts      = [documentsDirectory stringByAppendingPathComponent:@"VisitedPosts.plist"];
        pathToCommentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"comment_cache"];
        
        [self loadVisitedPosts];
        [self loadYakCache];
        [self readCommentCacheDirectory];
        [self cleanCommentCaches];
    }
}

+ (void)loadVisitedPosts {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToVisitedPosts isDirectory:nil]) {
        [visitedPostIdentifiers addObjectsFromArray:[NSArray arrayWithContentsOfFile:pathToVisitedPosts]];
    } else {
        if (![@[] writeToFile:pathToVisitedPosts atomically:YES]) {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to to save visited posts to disk"];
        }
    }
}

+ (void)loadYakCache {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToYaks isDirectory:nil]) {
        // Load and unarchive yaks
        [yaks addObjectsFromArray:[[NSArray arrayWithContentsOfFile:pathToYaks] arrayByApplyingBlockToElements:^id(NSData *data) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }]];
    } else {
        if (![@[] writeToFile:pathToYaks atomically:YES]) {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to to create yak cache"];
        }
    }
}

+ (void)readCommentCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCommentsDirectory isDirectory:nil]) {
        NSArray *comments = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCommentsDirectory error:nil];
        
        NSArray *commentPaths = [comments arrayByApplyingBlockToElements:^id(NSString *filename) {
            return [pathToCommentsDirectory stringByAppendingPathComponent:filename];
        }];
        NSArray *yakIdentifiers = [comments arrayByApplyingBlockToElements:^id(NSString *name) {
            return [name stringByReplacingOccurrencesOfString:@".plist" withString:@""];
        }];
        
        [pathsToCommentCaches addEntriesFromDictionary:[NSDictionary dictionaryWithObjects:commentPaths forKeys:yakIdentifiers]];
    }
    else {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] createDirectoryAtPath:pathToCommentsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to create yak comment cache directory: %@", error.localizedDescription];
        }
    }
}

#pragma mark Yaks

+ (NSOrderedSet<YYYak*> *)yakCache {
    return yaks;
}

+ (void)cleanYakCache {
    NSDate *now = [NSDate date];
    NSInteger daysToKeepHistory = [NSUserDefaults daysToKeepHistory];
    
    // Remove old yaks
    NSMutableArray *toRemove = [NSMutableArray array];
    for (YYYak *yak in yaks) {
        if ([yak.created daysBeforeDate:now] > daysToKeepHistory) {
            [toRemove addObject:yak];
        }
    }
    [yaks removeObjectsInArray:toRemove];
    
    // Sort from newest to oldest
    [yaks sortUsingComparator:^NSComparisonResult(YYYak *obj1, YYYak *obj2) {
        return [obj1.created compare:obj2.created];
    }];
    
    // Trim cache to 10000
    NSInteger overflow = yaks.count - kYakCacheSize;
    if (overflow > 0) {
        NSRange trim = NSMakeRange(kYakCacheSize, overflow);
        [yaks removeObjectsInRange:trim];
    }
}

+ (void)addToCache:(YYYak *)yak {
    // Remove first so we keep the most up to date yak.
    // Cache is only trimmed on application launch.
    [yaks removeObject:yak];
    [yaks addObject:yak];
}

#pragma mark Comments

+ (NSArray<YYComment*> *)commentsForYakWithIdentifier:(NSString *)identifier {
    NSString *path = pathsToCommentCaches[identifier];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        
        // Load comments at path, unarchive
        NSArray *comments = [NSArray arrayWithContentsOfFile:path];
        comments = [comments arrayByApplyingBlockToElements:^id(NSData *data) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }];
        
        NSAssert(comments.count, @"Comments are only archived if there are more than 0 of them, something is wrong");
        return comments;
    }
    
    return nil;
}

+ (void)cacheComments:(NSArray<YYComment*> *)comments forYak:(YYYak *)yak {
    NSArray *cached = [self commentsForYakWithIdentifier:yak.identifier];
    cached = cached ?: @[];
    
    // Combine comments such that we only store the most recent
    TTFeedArray *toCache = [TTFeedArray array];
    [toCache addObjectsFromArray:cached];
    [toCache addObjectsFromArray:comments];
    
    // Get path or create path and store it
    NSString *path = pathsToCommentCaches[yak.identifier];
    if (!path) {
        path = [pathToCommentsDirectory stringByAppendingPathComponent:[yak.identifier stringByAppendingString:@".plist"]];;
        pathsToCommentCaches[yak.identifier] = path;
    }
    
    [toCache.array archiveRootObjectsAndWriteToFile:path atomically:YES];
}

+ (void)cleanCommentCaches {
    NSDate *now = [NSDate date];
    NSInteger daysToKeepHistory = [NSUserDefaults daysToKeepHistory];
    
    // Remove caches over N days old
    NSMutableArray *toRemove = [NSMutableArray array];
    [pathsToCommentCaches enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, NSString *path, BOOL *stop) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        if (attributes) {
            if ([[attributes fileCreationDate] daysBeforeDate:now] > daysToKeepHistory) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                [toRemove addObject:identifier];
            }
        }
    }];
    [pathsToCommentCaches removeObjectsForKeys:toRemove];
}

#pragma mark Visited posts

+ (NSOrderedSet<NSString*> *)visitedPosts {
    return visitedPostIdentifiers;
}

+ (void)addVisitedPost:(NSString *)identifier {
    [visitedPostIdentifiers addObject:identifier];
}

@end
