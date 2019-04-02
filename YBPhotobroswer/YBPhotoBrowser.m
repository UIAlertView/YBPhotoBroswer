//
//  YBPhotoBrowser.m
//  YBPhotoBroswer
//
//  Created by zhaoyunbo on 2019/3/22.
//  Copyright © 2019年 zhaoyunbo. All rights reserved.
//
/** 注释
 只有UICollectionView背景色不透明
 */
#import "YBPhotoBrowser.h"
#import <POP.h>
#import <UIImageView+WebCache.h>

/**
 * 屏幕适配--iPhoneX全系
 */
#define IS_PB_iPhoneXAll ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896)
#define PB_SCREEN_W [UIScreen mainScreen].bounds.size.width
#define PB_SCREEN_H [UIScreen mainScreen].bounds.size.height

@interface YBPhotoBrowser ()<UIGestureRecognizerDelegate,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGRect _originalFrame;
    BOOL   _isFirst;
}
@property (nonatomic,assign) CGFloat totalScale; //用于记录视图即时的缩放比例
/** */
@property (nonatomic,assign) NSInteger index;
/** */
@property (nonatomic,strong) YBPhotoBrowserImageView *transitionImageView;

@property (nonatomic,copy) NSArray *urls;
/** 1/2 */
@property (nonatomic,strong) UILabel *textLabel;
/** */
@property (nonatomic,strong) UICollectionView *collectionView;
/** */
@property (nonatomic,strong) NSArray *fromViews;
@end

@implementation YBPhotoBrowser
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(PB_SCREEN_W, PB_SCREEN_H);
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        _collectionView.frame = CGRectMake(0, 0, PB_SCREEN_W, PB_SCREEN_H);
    }
    return _collectionView;
}
- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]init];
        _textLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        _textLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
        _textLabel.font = [UIFont systemFontOfSize:16];
        _textLabel.frame = CGRectMake(0,IS_PB_iPhoneXAll?PB_SCREEN_H-34-40-10:PB_SCREEN_H-40-10, PB_SCREEN_W, 40);
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}
- (void)setUseWhiteBackgroundColor:(BOOL)useWhiteBackgroundColor{
    _useWhiteBackgroundColor = useWhiteBackgroundColor;
    self.textLabel.textColor = _useWhiteBackgroundColor?[[UIColor blackColor] colorWithAlphaComponent:0.0]:[[UIColor whiteColor] colorWithAlphaComponent:0.0];
    self.collectionView.backgroundColor = _useWhiteBackgroundColor?[[UIColor whiteColor] colorWithAlphaComponent:.0]:[[UIColor blackColor] colorWithAlphaComponent:.0];
}
//- (instancetype)initWithFromView:(UIView *)fromView index:(NSInteger)index
//{
//    self = [super init];
//    if (self) {
//        self.modalPresentationStyle = UIModalPresentationCustom;
//        self.index = index;
//        //原尺寸
//        _originalFrame = [fromView.superview convertRect:fromView.frame toView:nil];
//    }
//    return self;
//}
- (instancetype)initWithFromViews:(NSArray *)fromViews urls:(NSArray *)urls index:(NSInteger)index{
    self = [super init];
    if (self) {
       
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.urls = urls;
        self.index = index;
        self.fromViews = fromViews;
        self.usePopAnimation = YES;
        self.useWhiteBackgroundColor = YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _isFirst = YES;
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self setUI];
    
    
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.useWhiteBackgroundColor ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (void)setUI{
    if (self.urls.count == 0)return;
    [self.view addSubview:self.textLabel];
    self.textLabel.hidden = (self.urls.count==1);
}
/** 相对于屏幕的rect */
- (CGRect)getOriginalFrame{
    UIView *fromView;
    if (self.fromViews.count == 1) {
        fromView = self.fromViews[0];
    }
    else{
        fromView = self.fromViews[self.index];
    }
    //相对于父视图的位置
    return [fromView.superview convertRect:fromView.frame toView:nil];
}
#pragma mark - Delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.urls) {
        return self.urls.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"identifier%lu",indexPath.row];
    [collectionView registerClass:[YBPhotoBrowserCell class] forCellWithReuseIdentifier:identifier];
    YBPhotoBrowserCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (_isFirst && indexPath.row == self.index) {
        cell.imageView.alpha = 0;
        _isFirst = NO;
        [cell.imageView sd_setImageWithURL:self.urls[indexPath.row] placeholderImage:[UIImage imageNamed:@"app_default"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            cell.imageView.alpha = 1;
            cell.imageView.isError = error;
            self.transitionImageView = cell.imageView;
            [self show];
        }];
    }
    else{
        cell.imageView.alpha = 1;
        [cell.imageView sd_setImageWithURL:self.urls[indexPath.row] placeholderImage:[UIImage imageNamed:@"app_default"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            cell.imageView.isError = error;
        }];
    }
    
    cell.singleBlock = ^(NSString *gest) {
        [self hide];
    };
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger offset = scrollView.contentOffset.x/scrollView.frame.size.width;
    if (offset == self.index) return;
    self.index = offset;
    /** 滑动到了第几张 */
    if ([self.pb_delegate respondsToSelector:@selector(photoBrowserScrollWithIndex:)]) {
        [self.pb_delegate photoBrowserScrollWithIndex:self.index];
    }
}
- (void)setIndex:(NSInteger)index{
    _index = index;
    if (!self.textLabel.hidden) {
        NSString *string = [NSString stringWithFormat:@"%@/%lu",@(_index+1),self.urls.count];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange range = [string rangeOfString:@"/"];
        NSLog(@"range.location :%lu",range.location);
        if (range.location != NSNotFound) {
            [attributedStr addAttribute:NSFontAttributeName
                                  value:[UIFont systemFontOfSize:23]
                                  range:NSMakeRange(0,range.location)];
        }
        self.textLabel.attributedText = attributedStr;
        
    }
}
- (void)show{
    
    self.textLabel.textColor = self.useWhiteBackgroundColor?[[UIColor blackColor] colorWithAlphaComponent:1.0]:[[UIColor whiteColor] colorWithAlphaComponent:1.0];
    
    if (self.transitionImageView.isError || !self.usePopAnimation) {
        self.collectionView.backgroundColor = self.useWhiteBackgroundColor?[[UIColor whiteColor] colorWithAlphaComponent:1.0]:[[UIColor blackColor] colorWithAlphaComponent:1.0];
        return;
    }
    
    [UIView animateWithDuration:.4 animations:^{
        self.collectionView.backgroundColor = self.useWhiteBackgroundColor?[[UIColor whiteColor] colorWithAlphaComponent:1.0]:[[UIColor blackColor] colorWithAlphaComponent:1.0];
    }];
    
    self.transitionImageView.userInteractionEnabled = NO;
    _originalFrame = [self getOriginalFrame];
    self.transitionImageView.frame = _originalFrame;
    POPBasicAnimation *holderShow = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    holderShow.duration = .4;
    holderShow.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, PB_SCREEN_W, PB_SCREEN_H)];
    [self.transitionImageView pop_addAnimation:holderShow forKey:@"show"];
    holderShow.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.transitionImageView.userInteractionEnabled = YES;
    };
}
- (void)hide{
    
    if ([self.collectionView visibleCells].count == 0) return;
    
    /** 点击了第几张hide */
    if ([self.pb_delegate respondsToSelector:@selector(photoBrowserClickWithIndex:)]) {
        [self.pb_delegate photoBrowserClickWithIndex:self.index];
    }
    
    self.textLabel.hidden = YES;
   
    YBPhotoBrowserCell *cell = (YBPhotoBrowserCell *)[self.collectionView visibleCells][0];
    self.transitionImageView = cell.imageView;
    
    _originalFrame = [self getOriginalFrame];

    //包含
    //BOOL contains = CGRectContainsRect(CGRectMake(0, 0, PB_SCREEN_W, PB_SCREEN_H), _originalFrame);
    //if (self.transitionImageView.isError || !contains) {
    
    /**  */
    if (self.transitionImageView.isError || !self.usePopAnimation) {
        [UIView animateWithDuration:.4 animations:^{
            self.collectionView.alpha = .0;
        } completion:^(BOOL finished) {
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        //[self dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    
    
    [UIView animateWithDuration:.4 animations:^{
        self.collectionView.backgroundColor = self.useWhiteBackgroundColor?[[UIColor whiteColor] colorWithAlphaComponent:0.0]:[[UIColor blackColor] colorWithAlphaComponent:0.0];
    }];
    self.transitionImageView.userInteractionEnabled = NO;
    POPBasicAnimation *holderHide = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    holderHide.duration = .4;
    CGRect transitionImageViewRect = [self.transitionImageView.superview convertRect:self.transitionImageView.frame toView:nil];
    
    holderHide.toValue = [NSValue valueWithCGRect:CGRectMake(_originalFrame.origin.x-transitionImageViewRect.origin.x, _originalFrame.origin.y-transitionImageViewRect.origin.y, _originalFrame.size.width, _originalFrame.size.height)];
    
    [self.transitionImageView pop_addAnimation:holderHide forKey:@"hide"];
    holderHide.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        self.transitionImageView.userInteractionEnabled = YES;
        [self dismissViewControllerAnimated:NO completion:nil];
    };
    
    
}


@end


#pragma mark - **************** YBPhotoBrowserImageView
@implementation YBPhotoBrowserImageView
@end


#pragma mark - **************** YBPhotoBrowserCell
#define minZoom 1.0
#define maxZoom 2.0
@interface YBPhotoBrowserCell ()<UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    CGRect _factSize;
}

@end

@implementation YBPhotoBrowserCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        self.contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        [self setUI];
    }
    return self;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        _scrollView.frame = CGRectMake(0, 0, PB_SCREEN_W, PB_SCREEN_H);
        _scrollView.bounces = YES;
        _scrollView.minimumZoomScale = minZoom;
        _scrollView.maximumZoomScale = maxZoom;
        _scrollView.delegate = self;
    }
    return _scrollView;
}
- (YBPhotoBrowserImageView *)imageView {
    if (!_imageView) {
        _imageView = [[YBPhotoBrowserImageView alloc]init];
        _imageView.frame = CGRectMake(0, 0, PB_SCREEN_W, PB_SCREEN_H);
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
        //一个手指
        UITapGestureRecognizer *singleClickDog = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleDogTap:)];
        UITapGestureRecognizer *doubleClickTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        singleClickDog.numberOfTapsRequired = 1;
        singleClickDog.numberOfTouchesRequired = 1;
        doubleClickTap.numberOfTapsRequired = 2;//需要点两下
        doubleClickTap.numberOfTouchesRequired = 1;//需要两个手指touch
        
        [_imageView addGestureRecognizer:singleClickDog];
        [_imageView addGestureRecognizer:doubleClickTap];
        [singleClickDog requireGestureRecognizerToFail:doubleClickTap];//如果双击了，则不响应单击事件
    }
    return _imageView;
}
- (void)setUI{
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        //self.scrollView.automaticallyAdjust
    }
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.contentSize = CGSizeMake(PB_SCREEN_W, PB_SCREEN_H);
}
#pragma mark - 事件处理
-(void)singleDogTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_singleBlock) {
        _singleBlock(@"单击");
    }
}
-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
    CGFloat zoomScale = [_scrollView zoomScale];
    zoomScale = (zoomScale == minZoom) ? maxZoom : minZoom;
    CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [_scrollView zoomToRect:zoomRect animated:YES];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    float scale = _scrollView.zoomScale;
    if (scale <= 1) {
        _scrollView.contentInset = UIEdgeInsetsZero;
    }
    else{
        CGSize size = [self imageFactSizeWithImage:self.imageView.image];
        /** 放大后空白区域显示问题 */
        
        //PB_SCREEN_H*scale 等价于 scrollView.contentSize.height
        CGFloat top = size.height*scale > PB_SCREEN_H ?-(PB_SCREEN_H-size.height)*scale/2.f:-(PB_SCREEN_H*scale-PB_SCREEN_H)/2.0;
        CGFloat bottom = top;
        CGFloat left = size.width*scale > PB_SCREEN_W ?-(PB_SCREEN_W-size.width)*scale/2.f:-(PB_SCREEN_W*scale-PB_SCREEN_W)/2.0;
        CGFloat right = left;
        
        NSLog(@"UIEdgeInsetsMake :(%f,%f)",top,left);
        _scrollView.contentInset = UIEdgeInsetsMake(top, left, bottom, right);
        
    }
    
}

#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width = [_scrollView frame].size.width/scale;
    //原点x
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;
    return zoomRect;
}

#pragma mark - ScrollView Delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (CGSize)imageFactSizeWithImage:(UIImage *)image{
    CGFloat w;
    CGFloat h;
    //需要缩放到屏幕的高
    if (image.size.height/image.size.width > PB_SCREEN_H/PB_SCREEN_W) {
        w = PB_SCREEN_H/image.size.height * image.size.width;
        h = PB_SCREEN_H;
    }
    //需要缩放到屏幕的宽
    else{
        w = PB_SCREEN_W;
        h = PB_SCREEN_W/image.size.width * image.size.height;
    }
    return CGSizeMake(w, h);
}
@end




