//
//  ZFTestRecoderController.m
//  01_录音_播放Demo
//
//  Created by bailing on 2017/12/27.
//  Copyright © 2017年 zhufeng. All rights reserved.
//

#import "ZFTestRecoderController.h"
#import "ZFRecoderTool.h"
@interface ZFTestRecoderController ()<ZFRecoderToolDelegate>
@property (nonatomic,strong)UIImageView *zfimageView; //背景图片
@property (nonatomic,strong)UIButton *recordBt;
@property (nonatomic,strong)UIButton *playBt;
@property (nonatomic,strong)ZFRecoderTool *recoderTool;
@end
@implementation ZFTestRecoderController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //初始化recder
    self.recoderTool = [ZFRecoderTool ShareRecoderTool];
    self.recoderTool.delegate = self;
    //创建UI
    [self setupUI];
}
-(void)setupUI{
    self.zfimageView=[[UIImageView alloc] initWithFrame:CGRectMake(80,150,64,64)];
    self.zfimageView.image=[UIImage imageNamed:@"mic_0"];
    [self.view addSubview:self.zfimageView];
    
    //录音bt
    _recordBt=[[UIButton alloc] initWithFrame:CGRectMake(52,230,120,40)];
    [_recordBt setTitle:@"按住 说话" forState:UIControlStateNormal];
    [_recordBt setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    [_recordBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_recordBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    _recordBt.backgroundColor=[UIColor cyanColor];
    //down按下的时候
    [_recordBt addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
    //up抬起来
    [_recordBt addTarget:self action:@selector(endRecord:) forControlEvents:UIControlEventTouchUpInside];
    //取消了
    [_recordBt addTarget:self action:@selector(cancelRecord:) forControlEvents:UIControlEventTouchDragExit];
    _recordBt.layer.cornerRadius = 10;
    [self.view addSubview:_recordBt];
    //播放bt
    _playBt=[[UIButton alloc] initWithFrame:CGRectMake(190,230,80,40)];
    _playBt.adjustsImageWhenHighlighted=NO;
    [_playBt setTitle:@"播 放" forState:UIControlStateNormal];
    [_playBt setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _playBt.layer.cornerRadius = 10;
    _playBt.backgroundColor=[UIColor yellowColor];
    [_playBt addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playBt];
}
//down
-(void)startRecord:(UIButton *)sender{
    NSLog(@"开始录制");
    [self.recoderTool startRecodering];
}
//up
-(void)endRecord:(UIButton *)sender{
    //结束录制
    double currentTime = self.recoderTool.recoder.currentTime;
    NSLog(@"本次录制的时间为:%f",time);
    if (currentTime < 1) {
        //时间太短
        self.zfimageView.image = [UIImage imageNamed:@"mic_0"];
       // [self alertWithMessage:@"说话时间太短"];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.recoderTool stopRecodering];
            [self.recoderTool deleteAudioPath];
        });
    }
    else{
        //成功录音
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self.recoderTool stopRecodering];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.zfimageView.image=[UIImage imageNamed:@"mic_0"];
            });
        });
        NSLog(@"已成功录音");
    }
}
//drag
-(void)cancelRecord:(UIButton *)sender{
    self.zfimageView.image = [UIImage imageNamed:@"mic_0"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //消耗的处理
        [self.recoderTool stopRecodering];
        [self.recoderTool deleteAudioPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"录音已经取消了");
        });
    });
}
//播放的事件
-(void)play{
    [self.recoderTool playAudioFile];
}
#pragma mark ZFRecoderToolDelegate
-(void)updateVolumeMeters:(CGFloat)value{
    NSInteger no=0;
    if (value>0&&value<=0.14) {
        no = 1;
    } else if (value<= 0.28) {
        no = 2;
    } else if (value<= 0.42) {
        no = 3;
    } else if (value<= 0.56) {
        no = 4;
    } else if (value<= 0.7) {
        no = 5;
    } else if (value<= 0.84) {
        no = 6;
    } else{
        no = 7;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"mic_%ld",(long)no];
    self.zfimageView.image = [UIImage imageNamed:imageName];
}
-(void)recordFinishWithUrl:(NSString *)url isSuccess:(BOOL)isSuccess{
    NSLog(@"录制成功了了");
}
- (void)didReceiveMemoryWarning {

}
@end
