//
//  NSString+URLTypes.h
//
//  Created by Tanner on 9/24/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

@property (nonatomic, readonly) BOOL isEmpty;
@property (nonatomic, readonly) BOOL hasHttpOrHttpsPrefix;

- (NSAttributedString *)attributedString;

- (BOOL)isEqualtoStringCaseInsensitive:(NSString *)string;

- (NSURL *)cleanURL;
- (NSString *)cleanURLString;

+ (NSString *)timeSinceNowFromDate:(NSDate *)date;
+ (NSString *)longTimeSinceNowFromDate:(NSDate *)date;

- (NSAttributedString *)withColor:(UIColor *)color;

- (NSString *)stringByDeletingCharacterAtIndex:(NSUInteger)idx;

@end


@interface NSString (Encoding)

- (NSData *)base64DecodedData;
- (NSString *)base64Encode;
- (NSString *)base64Decode;
- (NSString *)sha256Hash;
- (NSData *)sha256HashRaw;

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key;
+ (NSString *)hashHMacToString:(NSString *)data key:(NSString *)key;

- (NSString *)MD5Hash;

@end


@interface NSString (REST)

+ (NSString *)timestamp;
+ (NSString *)timestampFrom:(NSDate *)date;
+ (NSString *)queryStringWithParams:(NSDictionary *)params;
+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues;

@end


@interface NSString (Regex)

- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)textFromHTML;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;

@end