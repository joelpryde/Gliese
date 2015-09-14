//
//  Globals.h
//  gliese
//
//  Created by Joel Pryde on 3/5/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#include <Accelerate/Accelerate.h>

void ConvertInt16ToFloat(AudioStreamBasicDescription audioFormat, void *buf, float *outputBuf, size_t capacity);
float MagnitudeSquared(float x, float y);
static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData);

@interface Globals : NSObject
{
    AudioUnit _audioUnit;
    AudioStreamBasicDescription _audioFormat;
    double _audioLevel;
    double _averageLevel;
    
    // fft
    double _sampleRate;
    FFTSetup _fftSetup;
    COMPLEX_SPLIT _A;
    int _log2n;
    int _nOver2;
    void* _dataBuffer;
	float* _outputBuffer;
    float* _currentBuffer;
    int _outputBufferSize;
	size_t _bufferCapacity;
	size_t _index;
    
    double _peakLevel;
    double _averageStorage[60];
    int _currentAverageIdx;
    int _peakSwitch;
    double _peakElapsed;
}

@property (readonly) AudioUnit audioUnit;
@property double audioLevel;
@property double averageLevel;

@property (readonly) float* currentBuffer;
@property (readonly) int outputBufferSize;

+(Globals*)Instance;

-(void)setupAudioUnit;
-(void)startAudioUnit;
-(void)stopAudioUnit;
-(void)finishAudioUnit;

-(double)updateAudioPeak;

// fft
-(void)DSPSetup:(double)sampleRate;
-(void)DSPRender:(uint32_t)numFrames Buffer:(AudioBufferList*)ioData;

@end
