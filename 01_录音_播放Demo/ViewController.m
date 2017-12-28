//
//  ViewController.m
//  01_录音_播放Demo
//
//  Created by bailing on 2017/12/27.
//  Copyright © 2017年 zhufeng. All rights reserved.
//

#define zf_ScrrenWidth  [UIScreen mainScreen].bounds.size.width
#define zf_ScrrenHeight [UIScreen mainScreen].bounds.size.height
#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//这个库是C的接口，偏向于底层，主要用于在线流媒体的播放
#import <AVFoundation/AVFoundation.h>
//提供了音频和回放的底层的api，同时也负责管理音频硬件
@interface ViewController () <AVAudioRecorderDelegate>
//录音的对象类
@property(nonatomic,strong)AVAudioRecorder *recoder;
//定时器检查声音
@property (nonatomic,strong)NSTimer *timer;
//录音时候的图片
@property (nonatomic,strong)UIImageView *myImageV;
//录制的button
@property (nonatomic,strong)UIButton *recderBtn;
//播放的button
@property (nonatomic,strong)UIButton *playButton;
//播放的url
@property (nonatomic,strong)NSURL *urlPlay;
//播放的对象
@property (nonatomic,strong)AVAudioPlayer *player;

@end
@implementation ViewController
//录音的图片
-(UIImageView *)myImageV{
    if (!_myImageV) {
        _myImageV = [[UIImageView alloc]initWithFrame:CGRectMake((zf_ScrrenWidth-60)/2, 30, 60, 60)];
        _myImageV.image = [UIImage imageNamed:@"mic_0.png"];
        //图片的模式
        _myImageV.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _myImageV;
}
-(UIButton *)recderBtn{
    if (!_recderBtn) {
        _recderBtn = [[UIButton alloc]initWithFrame:CGRectMake((zf_ScrrenWidth-80)/2, 130, 40, 40)];
        _recderBtn.backgroundColor = [UIColor blackColor];
        [_recderBtn setTitle:@"开始" forState:UIControlStateNormal];
        _recderBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [_recderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //添加事件了
        // 按下的东西
        [_recderBtn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
        //抬起来
        [_recderBtn addTarget:self action:@selector(btnUp:) forControlEvents:UIControlEventTouchUpInside];
        //拖拽方式
        [_recderBtn addTarget:self action:@selector(btnDrag:) forControlEvents:UIControlEventTouchDragExit];
    }
    return _recderBtn;
}
-(UIButton *)playButton{
    if (!_playButton) {
        _playButton = [[UIButton alloc]initWithFrame:CGRectMake((zf_ScrrenWidth-60)/2+40, 130, 40, 40)];
        _playButton.backgroundColor = [UIColor redColor];
        [_playButton setTitle:@"播放" forState:UIControlStateNormal];
        _playButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_playButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(btnPlay:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化录音的设置
    [self setupAudio];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detecoVoice) userInfo:nil repeats:YES];
    [self.view addSubview:self.myImageV];
    [self.view addSubview:self.playButton];
    [self.view addSubview:self.recderBtn];
}
-(void)detecoVoice{
    [self.recoder updateMeters];
    //获取音量的平均值
    //[recorder averagePowerForChannel:0];
    //音量的最大值
    //[recorder peakPowerForChannel:0];
    NSInteger no=0;
    NSLog(@"[_recorder peakPowerForChannel:0]:%f",[self.recoder peakPowerForChannel:0]);
    double value=pow(10,(0.05*[self.recoder peakPowerForChannel:0]));
    NSLog(@"value:%f",value);
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
    NSString *imageStr = [NSString stringWithFormat:@"mic_%ld",(long)no];
    self.myImageV.image = [UIImage imageNamed:imageStr];
}
#pragma mark --响应的事件了
-(void)btnDown:(UIButton *)sender{
    NSLog(@"Down");
    [sender setTitle:@"暂停" forState:UIControlStateNormal];
    if (self.recoder && [self.recoder prepareToRecord]) {
        NSLog(@"开始录制了音频了");
        [self.recoder record];
    }
}
-(void)btnUp:(UIButton *)sender{
    NSLog(@"Up");
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    double time = self.recoder.currentTime;
    NSLog(@"time:%f",time);
    if (time > 2) {
        NSLog(@"发送出去了");
    }else{
        NSLog(@"取消发送了");
    }
    [self.recoder stop];
    [self.timer invalidate];
}
-(void)btnDrag:(UIButton *)sender{
    NSLog(@"Drag");
    [sender setTitle:@"暂停" forState:UIControlStateNormal];
    [self.recoder stop];
    [self.timer invalidate];
}
#pragma mark - 播放的东西
-(void)btnPlay:(UIButton *)sender{
    NSLog(@"播放了");
    NSError *playError;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:self.urlPlay error:&playError];
    [self.player prepareToPlay];
    [self.player play];
}
// 设置录音的参数
-(void)setupAudio{
    //使用可变的字典
    NSMutableDictionary *recderSetting = [NSMutableDictionary dictionary];
    //设置录音格式pcm
    [recderSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置采样率 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recderSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //设置线性采样位数 9 16 24 32
    [recderSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //设置录音的质量
    [recderSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //设置录音的文件路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"zhufeng/Recoder.awv"];
    //判断文件是否存在
    //判断是否存在,不存在则创建
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSString *audioRecordDirectories = [filePath stringByDeletingLastPathComponent];
        [fileManager createDirectoryAtPath:audioRecordDirectories withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    //最后的url路径
    self.urlPlay = [NSURL fileURLWithPath:filePath];
    NSLog(@"self.urlPlay:%@",self.urlPlay);
    NSError *error;
    // 设置录音的文件
    self.recoder = [[AVAudioRecorder alloc]initWithURL:self.urlPlay settings:recderSetting error:&error];
    self.recoder.delegate = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
