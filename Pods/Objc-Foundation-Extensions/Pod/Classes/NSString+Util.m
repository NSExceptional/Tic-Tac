//
//  NSString+URLTypes.m
//
//  Created by Tanner on 9/24/14.
//
//

#import "NSString+Util.h"
#import "NSData+Util.h"
#import <CommonCrypto/CommonHMAC.h>

#define HOST [[self cleanURL] host]
#define COMPONENTS [CLEAN pathComponents]
#define CLEAN [self cleanURL]

#pragma mark - Utilities
@implementation NSString (Util)

- (NSAttributedString *)attributedString { return [[NSAttributedString alloc] initWithString:self]; }

- (BOOL)isEmpty { return [self isEqualToString:@""]; }

- (BOOL)isEqualtoStringCaseInsensitive:(NSString *)string {
    return [self compare:string options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

- (NSURL *)cleanURL {
    return [NSURL URLWithString:[self cleanURLString]];
}

- (NSString *)cleanURLString {
    NSMutableString *cleaned = self.mutableCopy;
    NSURL *url = [NSURL URLWithString:self];
    // add URL scheme
    if (![url scheme])
        [cleaned insertString:@"https://" atIndex:0];
    
    // Remove parameters, queries, and fragments
    // and the preceeding character (?, ;, #)
    NSMutableArray *partsToRemove = [NSMutableArray array];
    if (url.parameterString)
        [partsToRemove addObject:[NSString stringWithFormat:@";%@", url.parameterString]];
    if (url.query)
        [partsToRemove addObject:[NSString stringWithFormat:@"?%@", url.query]];
    if (url.fragment)
        [partsToRemove addObject:[NSString stringWithFormat:@"#%@", url.fragment]];
    
    // Loop to remove occurences of the above
    for (NSString *part in partsToRemove) {
        NSRange range = [cleaned rangeOfString:part];
        [cleaned replaceCharactersInRange:range withString:@""];
    }
    
    return cleaned.copy;
}

- (BOOL)hasHttpOrHttpsPrefix {
    NSString *scheme = [NSURL URLWithString:self].scheme;
    return [scheme isEqualtoStringCaseInsensitive:@"http"] || [scheme isEqualtoStringCaseInsensitive:@"https"];
}

+ (NSString *)timeSinceNowFromDate:(NSDate *)date {
    NSInteger age = -round(date.timeIntervalSinceNow)/60;
    NSString *text;
    
    // if it was less than a minute, make it 1
    if (age < 1) age = 1;
    // if more than 59 minutes, convert to hours
    if (age > 59)
    {
        age /= 60;
        // if more than 23 hours, convert to days
        if (age > 23)
        {
            age /= 24;
            // if more than 365 days, convert to years
            if (age > 364)
            {
                age /= 365;
                text = [NSString stringWithFormat:@"%liy", (long)age];
            }
            else
                text = [NSString stringWithFormat:@"%lid", (long)age];
        }
        else
            text = [NSString stringWithFormat:@"%lih", (long)age];
    }
    else
        text = [NSString stringWithFormat:@"%lim", (long)age];
    
    return text;
}

+ (NSString *)longTimeSinceNowFromDate:(NSDate *)date {
    NSInteger age = -round(date.timeIntervalSinceNow)/60;
    NSString *text;
    
    // if it was less than a minute, make it 1
    if (age < 1) age = 1;
    // if more than 59 minutes, convert to hours
    if (age > 59)
    {
        age /= 60;
        // if more than 23 hours, convert to days
        if (age > 23)
        {
            age /= 24;
            // if more than 365 days, convert to years
            if (age > 364)
            {
                age /= 365;
                text = [NSString stringWithFormat:@"%li years", (long)age];
            }
            else
                text = [NSString stringWithFormat:@"%li days", (long)age];
        }
        else
            text = [NSString stringWithFormat:@"%li hours", (long)age];
    }
    else
        text = [NSString stringWithFormat:@"%li minutes", (long)age];
    
    if (age == 1)
        text = [text stringByReplacingOccurrencesOfString:@"s" withString:@""];
    return text;
}

- (NSAttributedString *)withColor:(UIColor *)color {
    NSParameterAssert(color);
    return [[NSAttributedString alloc] initWithString:self attributes:@{NSForegroundColorAttributeName: color}];
}

- (NSString *)stringByDeletingCharacterAtIndex:(NSUInteger)idx {
    NSMutableString *string = self.mutableCopy;
    [string replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
    return string;
}

@end


@implementation NSString (Encoding)

- (NSData *)base64DecodedData {
    return [[NSData alloc] initWithBase64EncodedString:self options:0];
}

- (NSString *)base64Encode {
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [stringData base64EncodedStringWithOptions:0];
}

- (NSString *)base64Decode {
    return [[NSString alloc] initWithData:self.base64DecodedData encoding:NSUTF8StringEncoding];
}

- (NSString *)sha256Hash {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256Hash];
}

- (NSData *)sha256HashRaw {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (unsigned int)data.length, result);
    
    data = [[NSData alloc] initWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
    
    return data;
}

+ (NSString *)hashHMacToString:(NSString *)data key:(NSString *)key {
    return [[self hashHMac:data key:key] base64EncodedStringWithOptions:0];
}

+ (NSData *)hashHMac:(NSString *)data key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}

- (NSString *)MD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end


@implementation NSString (REST)

+ (NSString *)timestamp {
    return [self timestampFrom:[NSDate date]];
}

+ (NSString *)timestampFrom:(NSDate *)date {
    NSTimeInterval time = date.timeIntervalSince1970;
    return [NSString stringWithFormat:@"%llu", (unsigned long long)round(time *1000.0)];
}

+ (NSString *)queryStringWithParams:(NSDictionary *)params {
    return [NSString queryStringWithParams:params URLEscapeValues:NO];
}

+ (NSString *)queryStringWithParams:(NSDictionary *)params URLEscapeValues:(BOOL)escapeValues {
    if (params.allKeys.count == 0) return @"";
    
    NSMutableString *q = [NSMutableString string];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        if ([value isKindOfClass:[NSString class]]) {
            if (value.length) {
                if (escapeValues) {
                    value = [value URLEncodedString];
                } else {
                    value = [value stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                }
                // Only append if len > 1
                [q appendFormat:@"%@=%@&", key, value];
            }
        } else {
            // Append if NSNumber or something
            [q appendFormat:@"%@=%@&", key, value];
        }
    }];
    
    [q deleteCharactersInRange:NSMakeRange(q.length-1, 1)];
    
    return q;
}

- (NSString *)URLEncodedString {
    NSMutableString *encoded    = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)self.UTF8String;
    NSInteger sourceLen         = (NSInteger)strlen((const char *)source);
    
    for (NSInteger i = 0; i < sourceLen; i++) {
        const unsigned char c = source[i];
        if (c == ' '){
            [encoded appendString:@"+"];
        } else if (c == '.' || c == '-' || c == '_' || c == '~' ||
                   (c >= 'a' && c <= 'z') ||
                   (c >= 'A' && c <= 'Z') ||
                   (c >= '0' && c <= '9')) {
            [encoded appendFormat:@"%c", c];
        } else {
            [encoded appendFormat:@"%%%02X", c];
        }
    }
    
    return encoded;
}

@end


@implementation NSString (Regex)

- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return nil;
    NSTextCheckingResult *match = matches[0];
    if (idx >= match.numberOfRanges) return nil;
    
    return [self substringWithRange:[match rangeAtIndex:idx]];
}

- (NSArray *)matchesForRegex:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
        return nil;
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matches.count == 0)
        return nil;
    
    return matches;
}

- (NSArray *)allMatchesForRegex:(NSString *)regex {
    NSArray *matches = [self matchesForRegex:regex];
    if (matches.count == 0) return @[];
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSTextCheckingResult *result in matches)
        [strings addObject:[self substringWithRange:[result rangeAtIndex:1]]];
    
    return strings;
}

- (NSString *)textFromHTML {
    if (!self.length)
        return @"";
    
    NSArray *strings = [self allMatchesForRegex:@"<title>(.*)<[^>]*>"];
    NSMutableString *text = [NSMutableString string];
    
    for (NSString *s in strings)
        if (s.length)
            [text appendFormat:@"%@—", s];
    [text deleteCharactersInRange:NSMakeRange(text.length-1, 1)];
    
    return text;
}

- (NSString *)stringByReplacingMatchesForRegex:(NSString *)pattern withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:pattern withString:replacement options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

@end