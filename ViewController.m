//
//  ViewController.m
//  YBPhotoBroswer
//
//  Created by zhaoyunbo on 2019/3/22.
//  Copyright © 2019年 zhaoyunbo. All rights reserved.
//

#import "ViewController.h"
#import "YBPhotoBrowser.h"
@interface ViewController ()<UIGestureRecognizerDelegate,YBPhotoBrowserDelegate>
{
    NSArray *_arr;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.img.contentMode = UIViewContentModeScaleAspectFit;
    self.img1.contentMode = UIViewContentModeScaleAspectFit;
    self.img2.contentMode = UIViewContentModeScaleAspectFit;
    self.img3.contentMode = UIViewContentModeScaleAspectFit;
    
    self.img.tag = 0;
    self.img1.tag = 1;
    self.img2.tag = 2;
    self.img3.tag = 3;
    
    
    self.img.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.img addGestureRecognizer:tap];
    
    self.img1.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.img1 addGestureRecognizer:tap1];
    
    self.img2.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.img2 addGestureRecognizer:tap2];
    
    self.img3.userInteractionEnabled = YES;
    UITapGestureRecognizer * tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [self.img3 addGestureRecognizer:tap3];
    
    _arr = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1553247090815&di=634cb3cd61a9598576c648887f632976&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201408%2F03%2F20140803014157_NH8zJ.jpeg",
             @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1553247090815&di=efbf67bed9025b0cd69af95591cd6809&imgtype=0&src=http%3A%2F%2Fdingyue.ws.126.net%2FkdxLK4JiNRUOrkwPf1WYdMG5AmUsgDAQLShjlTAXaIM561553048829728compressflag.png",
             @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1553247090815&di=b6f25df000da7d992d15b09f7d3953d7&imgtype=0&src=http%3A%2F%2Fimg.ph.126.net%2FO8V1lsYpTUFonRQbAB-lRA%3D%3D%2F6597347943100479738.jpg",
             @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1553247090815&di=c6f828f49430c807bc6ef9b5816ceb5f&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201505%2F08%2F20150508200825_V4ejC.jpeg"];
    
    
    [self.img sd_setImageWithURL:[NSURL URLWithString:_arr[0]]];
    [self.img1 sd_setImageWithURL:[NSURL URLWithString:_arr[1]]];
    [self.img2 sd_setImageWithURL:[NSURL URLWithString:_arr[2]]];
    [self.img3 sd_setImageWithURL:[NSURL URLWithString:_arr[3]]];

}

-(void)tap:(UITapGestureRecognizer *)gestureRecognizer{
    YBPhotoBrowser *vc = [[YBPhotoBrowser alloc]initWithFromViews:@[self.img,self.img1,self.img2,self.img3] urls:_arr  index:gestureRecognizer.view.tag];
    vc.pb_delegate = self;
    //vc.usePopAnimation = NO;
    vc.useWhiteBackgroundColor = NO;
    [self presentViewController:vc animated:NO completion:nil];
}
- (void)photoBrowserClickWithIndex:(NSInteger)index{
    NSLog(@"点击了第%lu张",index);
}
-(void)photoBrowserScrollWithIndex:(NSInteger)index{
    NSLog(@"滑动到了第%lu张",index);
}

@end
