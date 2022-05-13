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
static NSCache<NSString*, NSMutableArray*> *yaksToComments;
static NSMutableOrderedSet *visitedPostIdentifiers;
static NSString *documentsDirectory;
static NSString *pathToYaks;
static NSString *pathToVisitedPosts;
static NSString *pathToCommentsDirectory;
static BOOL visitedPostsDelta = NO;
static BOOL yakCacheDelta     = NO;
static BOOL commentCacheDelta = NO;

static NSUInteger const kYakCacheSize = 2000;
static NSUInteger const kVisitedPostsSize = 10000;

@implementation TTCache

+ (void)initialize {
    if (self == [TTCache class]) {
        yaks                    = [NSMutableOrderedSet orderedSet];
        visitedPostIdentifiers  = [NSMutableOrderedSet orderedSet];
        pathsToCommentCaches    = [NSMutableDictionary dictionary];
        
        yaksToComments          = [NSCache new];
        yaksToComments.delegate = [self cacheDelegate];
        
        documentsDirectory      = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
        pathToYaks              = [documentsDirectory stringByAppendingPathComponent:@"YakCache.plist"];
        pathToVisitedPosts      = [documentsDirectory stringByAppendingPathComponent:@"VisitedPosts.plist"];
        pathToCommentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"comment_cache"];
        
        [self loadVisitedPosts];
        [self loadYakCache];
        [self readCommentCacheDirectory];
        [self cleanCommentCaches];
        [self cleanYakCache];
        
        [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(saveVisitedPosts) userInfo:nil repeats:YES];
        [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(saveYakCache) userInfo:nil repeats:YES];
    }
}

+ (instancetype)cacheDelegate {
    static TTCache *delegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [self new];
    });
    
    return delegate;
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
        NSArray *datas = [NSArray arrayWithContentsOfFile:pathToYaks];
        [yaks addObjectsFromArray:[datas arrayByApplyingBlockToElements:^id(NSData *data) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }]];
    } else {
        if (![@[] writeToFile:pathToYaks atomically:YES]) {
            [NSException raise:NSInternalInconsistencyException format:@"Unable to to create yak cache"];
        }
    }
}

/// Called on a 15 second interval
+ (void)saveVisitedPosts {
    if (visitedPostsDelta) {
        [visitedPostIdentifiers.array writeToFile:pathToVisitedPosts atomically:YES];
        visitedPostsDelta = NO;
    }
}

/// Called on a 15 second interval
+ (void)saveYakCache {
    if (yakCacheDelta) {
        [yaks.array archiveRootObjectsAndWriteToFile:pathToYaks atomically:YES];
        yakCacheDelta = NO;
    }
}

+ (void)readCommentCacheDirectory {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathToCommentsDirectory isDirectory:nil]) {
        NSArray *comments = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathToCommentsDirectory error:nil];
        
        NSArray *commentPaths = [comments arrayByApplyingBlockToElements:^id(NSString *filename) {
            return [pathToCommentsDirectory stringByAppendingPathComponent:filename];
        }];
        NSArray *yakIdentifiers = [comments arrayByApplyingBlockToElements:^id(NSString *name) {
            return [@"R/" stringByAppendingString:[name stringByReplacingOccurrencesOfString:@".plist" withString:@""]];
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

#pragma mark Comments

/// Used to serialize comments
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
    NSMutableArray<YYComment*> *comments = obj;
    [[self class] saveComments:comments forYakWithIdentifier:comments.firstObject.yakIdentifier];
}

+ (void)maybeSaveAllComments {
    if (commentCacheDelta) {
        commentCacheDelta = NO;
        for (NSArray<YYComment*> *comments in [yaksToComments valueForKey:@"allObjects"]) {
            [self saveComments:comments forYakWithIdentifier:comments.firstObject.yakIdentifier];
        }
    }
}

+ (void)saveComments:(NSArray *)comments forYakWithIdentifier:(NSString *)identifier {
    // Get path or create path and store it
    NSString *path = pathsToCommentCaches[identifier];
    if (!path) {
        NSString *filename = [identifier stringByReplacingOccurrencesOfString:@"R/" withString:@""];
        path = [pathToCommentsDirectory stringByAppendingPathComponent:[filename stringByAppendingString:@".plist"]];
        pathsToCommentCaches[identifier] = path;
    }
    
    [comments archiveRootObjectsAndWriteToFile:path atomically:YES];
}

+ (NSCache<NSString*, NSMutableArray<YYComment*>*> *)commentCache {
    return (id)yaksToComments;
}

+ (NSArray<YYComment*> *)commentsForYakWithIdentifier:(NSString *)identifier {
    return [self _commentsForYakWithIdentifier:identifier].copy;
}

//+ (NSMutableArray<YYComment*> *)_commentsForYakWithIdentifier:(NSString *)identifier {
//    return [yaksToComments objectForKey:identifier] ?: [self diskCachedCommentsForYakWithIdentifier:identifier] ?: [NSMutableArray array];
//}

+ (NSMutableArray<YYComment*> *)_commentsForYakWithIdentifier:(NSString *)identifier {
    id comments = [yaksToComments objectForKey:identifier];
    if (comments) {
        NSLog(@"Returning from memory cache");
        return comments;
    }
    comments = [self diskCachedCommentsForYakWithIdentifier:identifier];
    if (comments) {
        NSLog(@"Returning from disk cache");
        return comments;
    }
    return [NSMutableArray array];
}

+ (NSMutableArray<YYComment*> *)diskCachedCommentsForYakWithIdentifier:(NSString *)identifier {
    NSString *path = pathsToCommentCaches[identifier];
    if (path && [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:nil]) {
        
        // Load comments at path, unarchive
        NSArray *comments = [NSArray arrayWithContentsOfFile:path];
        comments = [comments arrayByApplyingBlockToElements:^id(NSData *data) {
            return [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }];
        
        NSAssert(comments.count, @"Comments are only archived if there are more than 0 of them, something is wrong");
        
        NSMutableArray *memory = [yaksToComments objectForKey:identifier];
        if (memory) {
            memory = [self mergeOld:memory into:comments];
        } else {
            memory = comments.mutableCopy;
        }
        [yaksToComments setObject:memory forKey:identifier cost:memory.count];
        return memory;
    }
    
    return nil;
}

+ (void)cacheComments:(NSArray<YYComment*> *)comments forYak:(YYYak *)yak {
    [self addToCommentCache:comments forYak:yak.identifier];
}

+ (void)cacheComment:(YYComment *)comment {
    commentCacheDelta = YES;
    
    // Remove first so we keep the most up to date yak.
    // Cache is only trimmed on application launch.
    NSMutableArray *comments = [self _commentsForYakWithIdentifier:comment.yakIdentifier];
    
    [comments removeObject:comment];
    [comments addObject:comment];
    [yaksToComments setObject:comments forKey:comment.yakIdentifier cost:comments.count];
}

+ (void)addToCommentCache:(NSArray<YYComment*> *)comments forYak:(NSString *)identifier {
    if (!comments.count) return;
    commentCacheDelta = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *cached = [self _commentsForYakWithIdentifier:identifier];
        
        // Add to memory cache
        cached = [self mergeOld:cached into:comments];
        [yaksToComments setObject:cached forKey:identifier cost:cached.count];
    });
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

+ (NSMutableArray *)mergeOld:(NSArray *)first into:(NSArray *)second {
    TTFeedArray *toCache = [TTFeedArray array];
    [toCache addObjectsFromArray:first];
    [toCache addObjectsFromArray:second];
    return toCache.array.mutableCopy;
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

+ (void)cacheYaks:(NSArray<YYYak*> *)newYaks {
    yakCacheDelta = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Remove first so we keep the most up to date yaks.
        // Cache is only trimmed on application launch.
        [yaks removeObjectsInArray:newYaks];
        [yaks addObjectsFromArray:newYaks];
    });
}

+ (void)cacheYak:(YYYak *)yak {
    yakCacheDelta = YES;
    
    // Remove first so we keep the most up to date yak.
    // Cache is only trimmed on application launch.
    [yaks removeObject:yak];
    [yaks addObject:yak];
}

+ (void)removeYakFromCache:(YYYak *)yak {
    yakCacheDelta = YES;
    [yaks removeObject:yak];
}

#pragma mark Visited posts

+ (NSOrderedSet<NSString*> *)visitedPosts {
    return visitedPostIdentifiers;
}

+ (void)addVisitedPost:(NSString *)identifier {
    visitedPostsDelta = YES;
    
    [visitedPostIdentifiers addObject:identifier];
    NSInteger difference = visitedPostIdentifiers.count - kVisitedPostsSize;
    if (difference > 0)
        [visitedPostIdentifiers removeObjectsInRange:NSMakeRange(0, difference)];
}

@end
