//
//  WBTimelineContentView.h
//  PPAsyncDrawingKit
//
//  Created by DSKcpp on 2016/11/10.
//  Copyright © 2016年 DSKcpp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPImageView;
@class WBTimelineItem;
@class WBTimelineTableViewCellDrawingContext;
@class WBTimelineTextContentView;
@class PPNameLabel;

@interface WBTimelineContentView : UIView
@property (nonatomic, strong) WBTimelineItem *timelineItem;
@property (nonatomic, strong) PPImageView *avatarView;
@property (nonatomic, strong) PPNameLabel *nameLabel;
@property (nonatomic, strong) WBTimelineTextContentView *textContentView;
@property (nonatomic, assign) CGFloat contentWidth;

+ (CGFloat)heightOfTimelineItem:(WBTimelineItem *)timelineItem withContentWidth:(CGFloat)width;
+ (CGFloat)heightOfTimelineItem:(WBTimelineItem *)timelineItem withContentWidth:(CGFloat)width userInfo:(NSDictionary *)userInfo;
+ (void)calculateContentHeightForDrawingContext:(WBTimelineTableViewCellDrawingContext *)drawingContext userInfo:(NSDictionary *)userInfo;
+ (WBTimelineTableViewCellDrawingContext *)validDrawingContextOfTimelineItem:(WBTimelineItem *)timelineItem withContentWidth:(CGFloat)width userInfo:(NSDictionary *)userInfo;
- (instancetype)initWithWidth:(CGFloat)width;
- (void)setTimelineItem:(WBTimelineItem *)timelineItem;
- (void)setTimelineItem:(WBTimelineItem *)timelineItem userInfo:(NSDictionary *)userInfo;
@end