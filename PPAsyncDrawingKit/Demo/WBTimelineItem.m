//
//  WBTimelineItem.m
//  PPAsyncDrawingKit
//
//  Created by DSKcpp on 2016/10/14.
//  Copyright © 2016年 DSKcpp. All rights reserved.
//

#import "WBTimelineItem.h"
#import "WBTimelineTableViewCell.h"
#import "WBTimelineAttributedTextParser.h"
#import "NSDate+PPASDK.h"
#import "NSAttributedString+PPExtendedAttributedString.h"
#import "WBHelper.h"

@implementation WBCardsModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"cards" : [WBCardModel class]};
}

@end

@implementation WBCardModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"card_group" : [WBCardModel class]};
}
@end

@implementation WBTimelineItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"pic_infos" : [WBTimelinePicture class],
             @"url_struct" : [WBURLStruct class]};
}
@end

@implementation WBUser

@end

@implementation WBTimelinePicture

@end

@implementation WBPictureMetadata

@end

@implementation WBTimelineTitle
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"structs" : [WBTImelineTitleStruct class]};
}
@end

@implementation WBTImelineTitleStruct

@end

@implementation WBURLStruct

@end

@implementation WBTimelinePageInfo

@end

@implementation WBPageActionLog

@end

@implementation WBTimelineTableViewCellDrawingContext
- (instancetype)initWithTimelineItem:(WBTimelineItem *)timelineItem
{
    if (self = [super init]) {
        _timelineItem = timelineItem;
        NSString *itemText = timelineItem.text;
        WBTimelineAttributedTextParser *parser = [WBTimelineAttributedTextParser textParserWithTimelineItem:timelineItem];
        WBTimelinePreset *preset = [WBTimelinePreset sharedInstance];
        if (itemText) {
            _textAttributedText = [[NSMutableAttributedString alloc] initWithString:itemText];
            [parser parserWithAttributedString:_textAttributedText
                                      fontSize:preset.textFont
                                     textColor:preset.textColor];
        }
        if (timelineItem.retweeted_status) {
            NSString *quotedItemText;
            if (timelineItem.retweeted_status.user.screen_name) {
                quotedItemText = [NSString stringWithFormat:@"@%@:%@", timelineItem.retweeted_status.user.screen_name, timelineItem.retweeted_status.text];
            } else {
                quotedItemText = timelineItem.retweeted_status.text;
            }
            if (quotedItemText.length > 0) {
                _quotedAttributedText = [[NSMutableAttributedString alloc] initWithString:quotedItemText];
                [parser parserWithAttributedString:_quotedAttributedText
                                          fontSize:preset.subtextFont
                                         textColor:preset.subtextColor];
            }
        }
        if (timelineItem.title) {
            NSString *title = timelineItem.title.text;
            _titleAttributedText = [[NSMutableAttributedString alloc] initWithString:title];
            [_titleAttributedText pp_setFont:[UIFont systemFontOfSize:preset.subtextFont]];
            [_titleAttributedText pp_setColor:preset.textColor];
        }
        _metaInfoAttributedText = [self source];
    }
    return self;
}

- (NSMutableAttributedString *)source
{
    WBTimelinePreset *preset = [WBTimelinePreset sharedInstance];
    
    NSString *createTime = [self stringWithTimelineDate:_timelineItem.created_at];
    NSMutableString *sourceText = [NSMutableString string];
    
    if (createTime.length) {
        [sourceText appendFormat:@"%@", createTime];
        [sourceText appendString:@"  "];
    }
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:sourceText];
    [attrString pp_setFont:[UIFont systemFontOfSize:12.0f]];
    [attrString pp_setColor:preset.textColor];
    
    if (_timelineItem.source.length) {
        NSString *source = _timelineItem.source;
        // <a href="sinaweibo://customweibosource" rel="nofollow">iPhone 5siPhone 5s</a>
        static NSRegularExpression *hrefRegex, *textRegex;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            hrefRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=href=\").+(?=\" )" options:kNilOptions error:NULL];
            textRegex = [NSRegularExpression regularExpressionWithPattern:@"(?<=>).+(?=<)" options:kNilOptions error:NULL];
        });
        NSTextCheckingResult *hrefResult, *textResult;
        NSString *href = nil, *text = nil;
        hrefResult = [hrefRegex firstMatchInString:source options:kNilOptions range:NSMakeRange(0, source.length)];
        textResult = [textRegex firstMatchInString:source options:kNilOptions range:NSMakeRange(0, source.length)];
        if (hrefResult && textResult && hrefResult.range.location != NSNotFound && textResult.range.location != NSNotFound) {
            href = [_timelineItem.source substringWithRange:hrefResult.range];
            text = [_timelineItem.source substringWithRange:textResult.range];
        }
        if (href.length && text.length) {
            NSMutableAttributedString *from = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"来自%@", text]];
            [from pp_setFont:[UIFont systemFontOfSize:12.0f]];
            [from pp_setColor:preset.textColor];
            if (_timelineItem.source_allowclick > 0) {
                NSRange range = NSMakeRange(2, text.length);
                PPTextHighlightRange *high = [[PPTextHighlightRange alloc] init];
                [from pp_setTextHighlightRange:high inRange:range];
                [from pp_setColor:preset.highlightTextColor inRange:range];
                PPTextBorder *border = [[PPTextBorder alloc] init];
                border.fillColor = preset.textBorderColor;
                [high setBorder:border];
            }
            [attrString appendAttributedString:from];
        }
    }
    return attrString;
}

- (NSString *)stringWithTimelineDate:(NSDate *)date {
    if (!date) return @"";
    
    static NSDateFormatter *formatterYesterday;
    static NSDateFormatter *formatterSameYear;
    static NSDateFormatter *formatterFullDate;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatterYesterday = [[NSDateFormatter alloc] init];
        [formatterYesterday setDateFormat:@"昨天 HH:mm"];
        [formatterYesterday setLocale:[NSLocale currentLocale]];
        
        formatterSameYear = [[NSDateFormatter alloc] init];
        [formatterSameYear setDateFormat:@"M-d"];
        [formatterSameYear setLocale:[NSLocale currentLocale]];
        
        formatterFullDate = [[NSDateFormatter alloc] init];
        [formatterFullDate setDateFormat:@"yy-M-dd"];
        [formatterFullDate setLocale:[NSLocale currentLocale]];
    });
    
    NSDate *now = [NSDate new];
    NSTimeInterval delta = now.timeIntervalSince1970 - date.timeIntervalSince1970;
    if (delta < -60 * 10) { // 本地时间有问题
        return [formatterFullDate stringFromDate:date];
    } else if (delta < 60 * 10) { // 10分钟内
        return @"刚刚";
    } else if (delta < 60 * 60) { // 1小时内
        return [NSString stringWithFormat:@"%d分钟前", (int)(delta / 60.0)];
    } else if (date.isToday) {
        return [NSString stringWithFormat:@"%d小时前", (int)(delta / 60.0 / 60.0)];
    } else if (date.isYesterday) {
        return [formatterYesterday stringFromDate:date];
    } else if (date.year == now.year) {
        return [formatterSameYear stringFromDate:date];
    } else {
        return [formatterFullDate stringFromDate:date];
    }
}

- (BOOL)hasQuoted
{
    return self.timelineItem.retweeted_status != nil;
}

- (BOOL)hasPhoto
{
    return self.timelineItem.pic_infos.count > 0 || self.timelineItem.retweeted_status.pic_infos.count > 0;
}

- (BOOL)hasTitle
{
    return self.timelineItem.title != nil;
}

@end

