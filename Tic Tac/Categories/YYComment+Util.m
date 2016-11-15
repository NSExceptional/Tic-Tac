//
//  YYComment+Util.m
//  Tic Tac
//
//  Created by Tanner on 5/3/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "YYComment+Util.h"


static NSDictionary *colorDescriptions;
static NSDictionary *iconDescriptions;
@implementation YYComment (Util)

- (NSString *)authorText {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorDescriptions = @{@"000": @"original",
                              @"001": @"red",
                              @"002": @"orange",
                              @"003": @"yellow",
                              @"004": @"lime",
                              @"005": @"blue",
                              @"006": @"purple",
                              @"007": @"pink",
                              @"008": @"grey", // light
                              @"009": @"grey", // dark
                              @"011": @"tan",
                              @"012": @"black",
                              @"013": @"grey",
                              @"014": @"brown",
                              @"015": @"red",
                              @"016": @"gold",
                              @"017": @"purple",
                              @"018": @"teal",
                              @"019": @"green",
                              @"020": @"navy",
                              @"025": @"heart",
                              @"030": @"white",
                              @"040": @"black"};
        iconDescriptions = @{@"000": @"poster",
                             @"001": @"canoe",
                             @"002": @"binoculars",
                             @"003": @"boot",
                             @"004": @"sailboat",
                             @"005": @"fire",
                             @"006": @"socks",
                             @"007": @"balloon",
                             @"008": @"anchor",
                             @"009": @"lantern",
                             @"010": @"compass",
                             @"011": @"hook",
                             @"012": @"paw",
                             @"013": @"map",
                             @"014": @"mushroom",
                             @"015": @"shovel",
                             @"016": @"paddles",
                             @"017": @"flashlight",
                             @"018": @"acorn",
                             @"019": @"teepee",
                             @"020": @"UFO",
                             @"021": @"church",
                             @"022": @"candy",
                             @"023": @"pot",
                             @"024": @"frankenstien",
                             @"025": @"ghost",
                             @"026": @"spiderweb",
                             @"027": @"freddy",
                             @"028": @"bone",
                             @"029": @"moon",
                             @"030": @"bat",
                             @"031": @"hat",
                             @"032": @"skull",
                             @"033": @"cat",
                             @"034": @"gravestone",
                             @"035": @"clown",
                             @"036": @"candycorn",
                             @"037": @"fangs",
                             @"038": @"coffin",
                             @"039": @"hand",
                             @"040": @"jackolantern",
                             @"041": @"skate",
                             @"042": @"snowflake",
                             @"043": @"glass",
                             @"044": @"ribbon",
                             @"045": @"candle",
                             @"046": @"snowglobe",
                             @"047": @"ornament",
                             @"048": @"holly",
                             @"049": @"candycane",
                             @"050": @"gingerbread",
                             @"051": @"sweater",
                             @"052": @"beanie",
                             @"053": @"mittens",
                             @"054": @"mug",
                             @"055": @"bells",
                             @"056": @"tree",
                             @"057": @"snowman",
                             @"058": @"present",
                             @"059": @"light",
                             @"060": @"dradle",};
    });
    
    NSString *color = colorDescriptions[self.backgroundIdentifier];
    NSString *icon  = iconDescriptions[self.overlayIdentifier];
    
    if (!color) {
        color = colorDescriptions[[self.backgroundIdentifier stringByReplacingOccurrencesOfString:@"WEB" withString:@""]];
    }
    
    if (self.username) {
        return [NSString stringWithFormat:@"%@ %@ | %@", color, icon, self.username];
    }
    
    return [NSString stringWithFormat:@"%@ %@", color, icon];
}

@end
