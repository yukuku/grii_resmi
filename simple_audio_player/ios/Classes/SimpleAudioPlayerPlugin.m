#import "SimpleAudioPlayerPlugin.h"
#import <AVFoundation/AVFoundation.h>

@implementation SimpleAudioPlayerPlugin

AVPlayer* player;
AVPlayerItem* pi;
id periodicTimeObserver;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"simple_audio_player"
                                     binaryMessenger:[registrar messenger]];
    
    SimpleAudioPlayerPlugin* instance = [[SimpleAudioPlayerPlugin alloc] init];
    instance.channel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)reinitPlayer {
    if (player != nil && periodicTimeObserver != nil) {
        [player removeTimeObserver:periodicTimeObserver];
        periodicTimeObserver = nil;
    }
    
    player = [AVPlayer new];
    periodicTimeObserver = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:nil usingBlock:^(CMTime time) {
        int ms = (int) (CMTimeGetSeconds(time) * 1000.0);
        [self.channel invokeMethod:@"onPosition" arguments:@(ms)];
    }];
}

- (void)dealloc {
    if (pi != nil) {
        [pi removeObserver:self forKeyPath:@"status"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSLog(@"%@, %@", keyPath, self.channel);
    
    if ([@"status" isEqualToString:keyPath]) {
        if ([pi status] == AVPlayerItemStatusReadyToPlay) {
            [self.channel invokeMethod:@"onStatus" arguments:@"paused"];
            [self.channel invokeMethod:@"onDuration" arguments:@((int)(CMTimeGetSeconds([pi duration]) * 1000.0))];
            [self.channel invokeMethod:@"onPosition" arguments:@(0)];
            [self.channel invokeMethod:@"onComplete" arguments:@(NO)];
            [self.channel invokeMethod:@"onError" arguments:nil];
        } else {
            [self.channel invokeMethod:@"onStatus" arguments:@"error"];
            [self.channel invokeMethod:@"onError" arguments:[NSString stringWithFormat:@"%@ %@", @"AVPlayerItemStatusFailed", [pi error]]];
        }
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString* method = call.method;
    
    if ([@"setDataSourceUrl" isEqualToString:method]) {
        NSString* url = call.arguments;
        if (pi != nil) {
            [pi removeObserver:self forKeyPath:@"status"];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        
        [self reinitPlayer];
        pi = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
        [pi addObserver:self forKeyPath:@"status" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:pi queue:nil usingBlock:^(NSNotification *note) {
            [player pause];
            [self.channel invokeMethod:@"onStatus" arguments:@"paused"];
            [self.channel invokeMethod:@"onComplete" arguments:@(YES)];
        }];
        
        [player replaceCurrentItemWithPlayerItem:pi];
        [self.channel invokeMethod:@"onError" arguments:nil];
        result(@(YES));
        
    } else if ([@"play" isEqualToString:method]) {
        [player play];
        result(@(YES));
        
    } else if ([@"pause" isEqualToString:method]) {
        [player pause];
        result(@(YES));
        
    } else if ([@"resume" isEqualToString:method]) {
        [player play];
        result(@(YES));
        
    } else if ([@"stop" isEqualToString:method]) {
        [player pause];
        result(@(YES));
        
    } else if ([@"dispose" isEqualToString:method]) {
        [player pause];
        result(@(YES));

    } else if ([@"seek" isEqualToString:method]) {
        NSNumber* ms = call.arguments;
        int32_t timeScale = player.currentItem.asset.duration.timescale;
        
        BOOL isPlaying = player.rate != 0 && player.error == nil;
        [player seekToTime:CMTimeMakeWithSeconds(ms.intValue / 1000.0, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            if (isPlaying) {
                [player play];
            }
        }];
        
        [self.channel invokeMethod:@"onComplete" arguments:@(NO)];
        result(@(YES));
        
    } else if ([@"tell" isEqualToString:method]) {
        int32_t ms = CMTimeGetSeconds([player currentTime])*1000;
        result([NSNumber numberWithInt:ms]);
        
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
