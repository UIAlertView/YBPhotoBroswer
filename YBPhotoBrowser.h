//
//  YBPhotoBrowser.h
//  YBPhotoBroswer
//
//  Created by zhaoyunbo on 2019/3/22.
//  Copyright © 2019年 zhaoyunbo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol YBPhotoBrowserDelegate <NSObject>
/** 点击文本框 */
@optional
/** 滑动到了第几张 */
- (void)photoBrowserScrollWithIndex:(NSInteger)index;
/** 点击了第几张隐藏的 */
- (void)photoBrowserClickWithIndex:(NSInteger)index;
@end
@interface YBPhotoBrowser : UIViewController
/** default YES*/
@property (nonatomic,assign) BOOL useWhiteBackgroundColor;
/** default YES */
@property (nonatomic,assign) BOOL usePopAnimation;
/** 返回的位置一样 */
//- (instancetype)initWithFromView:(UIView *)fromView index:(NSInteger)index;

/**fromViews.count 1返回的位置一样  >1返回的不位置一样 */
- (instancetype)initWithFromViews:(NSArray *)fromViews urls:(NSArray *)urls index:(NSInteger)index;
/** */
@property (nonatomic,weak) id<YBPhotoBrowserDelegate> pb_delegate;
@end


@class YBPhotoBrowserImageView;
@interface YBPhotoBrowserImageView : UIImageView
@property (nonatomic,assign) BOOL isError;
@end



@class YBPhotoBrowserCell;
typedef void(^HiddenBlcok)(NSString *gest);

@interface YBPhotoBrowserCell : UICollectionViewCell
@property (nonatomic,copy) HiddenBlcok singleBlock;
/** */
@property (nonatomic,strong) UIScrollView *scrollView;
/** */
@property (nonatomic,strong) YBPhotoBrowserImageView *imageView;
@end




