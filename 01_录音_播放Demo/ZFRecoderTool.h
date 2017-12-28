//
//  ZFRecoderTool.h
//  01_录音_播放Demo
//
//  Created by bailing on 2017/12/27.
//  Copyright © 2017年 zhufeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol ZFRecoderToolDelegate <NSObject>
/**
 *  更新音量分贝数峰值(0~1)
 */
-(void)updateVolumeMeters:(CGFloat)value;
/**
 *  录音结束(url为录音文件地址,isSuccess是否录音成功)
 */
-(void)recordFinishWithUrl:(NSString *)url isSuccess:(BOOL)isSuccess;

@end

@interface ZFRecoderTool : NSObject

@property (nonatomic,weak)id <ZFRecoderToolDelegate> delegate;

@property (nonatomic,strong) AVAudioPlayer *player;

@property (nonatomic,strong)AVAudioRecorder *recoder;

@property (nonatomic,strong)NSURL *recoderUrl;

+(instancetype)ShareRecoderTool;

//开始录制
-(void)startRecodering;
//停止录制
-(void)stopRecodering;
//停止播放
-(void)stopPlaying;
//删除文件夹
-(void)deleteAudioPath;
// 开始播放默认录音地址的录音文件(如果正在录音,会自动停止)
-(void)playAudioFile;

@end
