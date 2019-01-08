//
//  NSString+Score.h
//
//  Created by Nicholas Bruning on 5/12/11.
//  Copyright (c) 2011 Involved Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

enum{
    NSStringScoreOptionNone                         = 1 << 0,
    NSStringScoreOptionFavorSmallerWords            = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty     = 1 << 2
};

typedef NSUInteger NSStringScoreOption;

@interface NSString (Score)

- (float) scoreAgainst:(NSString *)otherString;
- (float) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness;
- (float) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options;

@end
