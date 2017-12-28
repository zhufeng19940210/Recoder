
//  ZFRecoderTool.m
//  01_录音_播放Demo
//
//  Created by bailing on 2017/12/27.
//  Copyright © 2017年 zhufeng. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>//这个库是C的接口，偏向于底层，主要用于在线流媒体的播放
#import <AVFoundation/AVFoundation.h>//提供了音频和回放的底层的api，同时也负责管理音频硬件
#import "ZFRecoderTool.h"
static ZFRecoderTool *util = nil;
@interface ZFRecoderTool()
@property (nonatomic,strong)AVAudioSession *session;
@property (nonatomic,strong)NSTimer *timer;
@end
@implementation ZFRecoderTool
+(instancetype)ShareRecoderTool{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        util = [[ZFRecoderTool alloc]init];
    });
    return util;
}
-(instancetype)init{
    if (self =[super init]) {
        _session = [AVAudioSession sharedInstance];
        [self createRecoder];
    }
    return self;
}
-(void)dealloc{
    if (_timer!=nil) {
        [_timer invalidate];
        _timer = nil;
    }
    [_session setActive:NO error:nil];
    _session = nil;
    //停止录音
    [self stopRecodering];
    [self stopPlaying];
}
#pragma mark -创建录音的相关的文件
-(void)createRecoder{
    //创建一个可变的字典
    NSMutableDictionary *recoderSetting = [NSMutableDictionary dictionary];
    //设置录音的格式
    [recoderSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recoderSetting setValue:[NSNumber numberWithInt:44100] forKey:AVSampleRateKey];
    //设置通道数 1 ， 2
    [recoderSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数   8 16 24 32
    [recoderSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recoderSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //创建文件
    self.recoderUrl = [ZFRecoderTool getAudioRecordFilePath];
    //errror
    NSError *error = nil;
    //初始化录制的对象
    self.recoder = [[AVAudioRecorder alloc]initWithURL:self.recoderUrl settings:recoderSetting error:&error];
    //开启音量分贝的检测
    self.recoder.meteringEnabled = YES;
    self.recoder.delegate = self;
    if (self.recoder&&[self.recoder prepareToRecord]) {
        NSLog(@"开始去测试了");
    }else{
        NSLog(@"错误的东西了");
    }
}
//录音的最终的数据
+(NSURL *)getAudioRecordFilePath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    NSString *filePath = [path stringByAppendingPathComponent:@"zhufeng/Recoder.wav"];
    //判断文件是否存在
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSString *audioRecordDirectories = [filePath stringByDeletingLastPathComponent];
        [fileManager createDirectoryAtPath:audioRecordDirectories withIntermediateDirectories:YES attributes:nil error:nil];
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    return [NSURL fileURLWithPath:filePath];
}
// 查看文件大小的东西
+(NSString *)fileSieAtpath:(NSString *)filePath{
    unsigned long long size = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        size = [[manager attributesOfItemAtPath:filePath error:nil]fileSize];
        if (size >= pow(10, 9)) {
            //size>=1GB
            return [NSString stringWithFormat:@"%.2fGB",size/pow(10, 9)];
        }else if (size >= pow(10, 6)){
            return  [NSString stringWithFormat:@"%.2fMB",size/pow(10, 6)];
        }else if (size  >= pow(10,3)){
            return  [NSString stringWithFormat:@"%.2fKB",size/pow(10,3)];
        }else{
            return  [NSString stringWithFormat:@"%zdB",size];
        }
    }
    return  @"0";
}
#pragma mark -开始录音
-(void)startRecodering{
    if (self.recoder == nil) {
        [self createRecoder];
    }
    //录音时候暂停播放
    [self stopPlaying];
    //设置会话的类型 (录制的类型)
    [self setAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord];
    //开始录制
    [self.recoder record];
    //开启定时器去检查声音的变化了
    [self createTimer];
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
}
// 设置AvAudioSession的类型
-(void)setAudioSessionCategory:(NSString *)category{
    NSError *sesssioinerror;
    // 设置会话的样式
    [self.session setCategory:category error:&sesssioinerror];
    //启动会话的管理
    if (self.session == nil || sesssioinerror) {
        NSLog(@"session会话错误的%@",sesssioinerror);
    }else{
        // 设置活跃了
        [self.session setActive:YES error:nil];
    }
}
#pragma mark -创建定时器
-(void)createTimer{
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(volumeMeters:) userInfo:nil repeats:YES];
        //将定时器加入到runLoop中去
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}
#pragma mark - 计时器
//音量音量分贝数监测
-(void)volumeMeters:(NSTimer *)timer{
    if (self.recoder && self.recoder.isRecording &&[self.delegate respondsToSelector:@selector(updateVolumeMeters:)]) {
        //刷新分贝
        [self.recoder updateMeters];
        //获取音量的平均值
        //[recorder averagePowerForChannel:0];
        //音量的最大值
        //[recorder peakPowerForChannel:0];
        double value = pow(10,(0.05*[self.recoder peakPowerForChannel:0]));
        if (value<0) {
            value = 0;
        }else if (value>1){
            value = 1;
        }
        [self.delegate updateVolumeMeters:value];
    }
}
#pragma mark - AVAudioRecorderDelegate
//录音结束
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    if (flag) {
        [self.session setActive:NO error:nil];
//        NSLog(@"CDPAudioRecorder录音完成,文件大小为%@",[ZFRecoderTool  fileSieAtpath:self.recoderUrl.absoluteString]);
    }
    if ([_delegate respondsToSelector:@selector(recordFinishWithUrl:isSuccess:)]) {
        [_delegate recordFinishWithUrl:self.recoderUrl.absoluteString isSuccess:flag];
    }
}
#pragma mark -结束录音
-(void)stopRecodering{
    if (self.recoder && [self.recoder isRecording]) {
        [self.recoder stop];
    }
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}
#pragma mark -停止播放
-(void)stopPlaying{
    if (self.player) {
        [self.player stop];
    }
}
//删除文件夹
-(void)deleteAudioPath{
    if (self.recoderUrl) {
        [self deleteFileWithUrl:self.recoderUrl.absoluteString];
    }
}
//删除录音的文件
-(void)deleteFileWithUrl:(NSString *)url{
    if ([url isEqualToString:@""] || url == nil || [url isKindOfClass:[NSNull class]]) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:[NSURL URLWithString:url] error:NULL];
}
-(void)playAudioFile{
    if (self.recoderUrl) {
        [self playAudioWithUrl:self.recoderUrl.absoluteString];
    }
}
//开始播放本地url音频(如果正在录音,会自动停止)
-(void)playAudioWithUrl:(NSString *)url{
    //播放的时候停止录音
    [self stopRecodering];
    //正在播放，停止了
    if (self.player&&[self.player isPlaying]) {
        [self.player stop];
    }
    if ([url isEqualToString:@""]) {
        NSLog(@"播放的url的为空了");
        return;
    }
    //设置会话类别
    [self setAudioSessionCategory:AVAudioSessionCategoryPlayback];
    NSError *playError;
    self.player = nil;
    self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:url] error:&playError];
    [self.player prepareToPlay];
    if (self.player == nil) {
        NSLog(@"CDPAudioRecorder播放音频player为nil--url：%@--error:%@",url,playError);
    }else{
        BOOL isPlay = [self.player play];
        if (isPlay==NO) {
            NSLog(@"CDPAudioRecorder播放音频失败url:%@---\n%@",url,playError);
        }
    }
}
@end
