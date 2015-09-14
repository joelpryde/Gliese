//
//  Globals.m
//  gliese
//
//  Created by Joel Pryde on 3/5/12.
//  Copyright (c) 2012 Physipop. All rights reserved.
//

#import "Globals.h"

#define kOutputBus 0
#define kInputBus 1

static OSStatus recordingCallback(void *inRefCon, 
                                  AudioUnitRenderActionFlags *ioActionFlags, 
                                  const AudioTimeStamp *inTimeStamp, 
                                  UInt32 inBusNumber, 
                                  UInt32 inNumberFrames, 
                                  AudioBufferList *ioData) 
{    
    AudioBuffer buffer;
    
    buffer.mNumberChannels = 1;
    buffer.mDataByteSize = inNumberFrames * 2;
    //NSLog(@"%ld", inNumberFrames);
    buffer.mData = malloc( inNumberFrames * 2 );
    
    // Put buffer in a AudioBufferList
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    
    OSStatus status;
    status = AudioUnitRender([Globals Instance].audioUnit, 
                             ioActionFlags, 
                             inTimeStamp, 
                             inBusNumber, 
                             inNumberFrames, 
                             &bufferList);  
    
    // calculate audio level
    SInt16 *audioData = (SInt16 *)(&bufferList)->mBuffers[0].mData;
    double average = 0.0;
    for(int i=0; i < inNumberFrames; i++)
    {
        //i sometimes doesn't get past 0, sometimes goes into 20s
        //NSLog(@"%f",q[i]);//returns NaN, 0.00, or some times actual data
        average += fabs((double)audioData[i])/32767.0;
    }
    double audioLevel = average/(double)inNumberFrames * 100.0;
    [Globals Instance].averageLevel = audioLevel * 0.01 + [Globals Instance].averageLevel * 0.99;
    [Globals Instance].audioLevel = (audioLevel * 0.1 + [Globals Instance].audioLevel * 0.9);
    
    // calculate fft bins
    [[Globals Instance] DSPRender:inNumberFrames Buffer:&bufferList];
    
    return status;
}

@implementation Globals

@synthesize audioUnit = _audioUnit;
@synthesize audioLevel = _audioLevel;
@synthesize averageLevel = _averageLevel;

@synthesize currentBuffer = _currentBuffer;
@synthesize outputBufferSize = _outputBufferSize;

static Globals* sharedInstance;

+(Globals*)Instance
{
    return sharedInstance;
}

-(id)init
{
    _peakSwitch = 1;
    _peakElapsed = 0.0;
    sharedInstance = self;
    _audioLevel = 0.0;
    _averageLevel = 0.0;
    return self;
}

-(void)setupAudioUnit
{
    OSStatus status;
    
    // Describe audio component
    AudioComponentDescription desc;
    desc.componentType = kAudioUnitType_Output;
    desc.componentSubType = kAudioUnitSubType_RemoteIO;
    desc.componentFlags = 0;
    desc.componentFlagsMask = 0;
    desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
    
    // Get audio units
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    
    // Enable IO for recording
    UInt32 flag = 1;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioOutputUnitProperty_EnableIO, 
                                  kAudioUnitScope_Input, 
                                  kInputBus,
                                  &flag, 
                                  sizeof(flag));

    /*
    // Enable IO for playback
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioOutputUnitProperty_EnableIO, 
                                  kAudioUnitScope_Output, 
                                  kOutputBus,
                                  &flag, 
                                  sizeof(flag));*/
    
    // Describe format
    _audioFormat.mSampleRate		= 44100.00;
    _audioFormat.mFormatID			= kAudioFormatLinearPCM;
    _audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audioFormat.mFramesPerPacket	= 1;
    _audioFormat.mChannelsPerFrame	= 1;
    _audioFormat.mBitsPerChannel	= 16;
    _audioFormat.mBytesPerPacket	= 2;
    _audioFormat.mBytesPerFrame		= 2;
    
    // Apply format
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Output, 
                                  kInputBus, 
                                  &_audioFormat, 
                                  sizeof(_audioFormat));
    /*
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioUnitProperty_StreamFormat, 
                                  kAudioUnitScope_Input, 
                                  kOutputBus, 
                                  &_audioFormat, 
                                  sizeof(_audioFormat));*/
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = self;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioOutputUnitProperty_SetInputCallback, 
                                  kAudioUnitScope_Global, 
                                  kInputBus, 
                                  &callbackStruct, 
                                  sizeof(callbackStruct));
        
    // Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(_audioUnit, 
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output, 
                                  kInputBus,
                                  &flag, 
                                  sizeof(flag));
    
    // setup dsp
    [self DSPSetup:_audioFormat.mSampleRate];
    
    // Initialise
    status = AudioUnitInitialize(_audioUnit);
}

-(void)startAudioUnit
{
    AudioOutputUnitStart(_audioUnit);
}

-(void)stopAudioUnit
{
    AudioOutputUnitStop(_audioUnit);
}

-(void)finishAudioUnit
{
    AudioUnitUninitialize(_audioUnit);
}

-(double)updateAudioPeak
{
    _peakElapsed += 1.0/30.0;
    _currentAverageIdx = (_currentAverageIdx + 1) % 60;
    _averageStorage[_currentAverageIdx] = _audioLevel;
    double aveVal = 0.0;
    for(int i = 0; i < 60; i++)
    {
        aveVal += _averageStorage[i];
    }
    double peakAvarage = aveVal/60.0;
    double overaverage = _audioLevel - (peakAvarage*1.2);
    
    if(overaverage > 0.0 && _peakElapsed > 0.2)
    {
        _peakSwitch = -1 * _peakSwitch;
        _peakElapsed = 0.0;
    }
    _peakLevel += 1.0/30.0 * _peakSwitch;
    return _peakLevel;
}

-(void)DSPSetup:(double)sampleRate
{
    _sampleRate = sampleRate;
    uint32_t maxFrames = 2048;
    _bufferCapacity = maxFrames;
    _dataBuffer = (void*)malloc(maxFrames * sizeof(SInt16));
	_outputBuffer = (float*)malloc(maxFrames *sizeof(float));
    _currentBuffer = (float*)malloc(maxFrames/2 *sizeof(float));
    
    _log2n = log2f(maxFrames);
    _outputBufferSize = 1 << _log2n;
    assert(_outputBufferSize == maxFrames);
    _nOver2 = maxFrames/2;
    _A.realp = (float*)malloc(_nOver2 * sizeof(float));
    _A.imagp = (float*)malloc(_nOver2 * sizeof(float));
    _fftSetup = vDSP_create_fftsetup(_log2n, FFT_RADIX2);
    
    for (int i=0; i<_outputBufferSize/2; i++)
        _currentBuffer[i] = 0.0;
}

void ConvertInt16ToFloat(AudioStreamBasicDescription audioFormat, void *buf, float *outputBuf, size_t capacity) 
{
	AudioConverterRef converter;
	OSStatus err;
	
	size_t bytesPerSample = sizeof(float);
	AudioStreamBasicDescription outFormat = {0};
	outFormat.mFormatID = kAudioFormatLinearPCM;
	outFormat.mFormatFlags = kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked;
	outFormat.mBitsPerChannel = (unsigned int)(8 * bytesPerSample);
	outFormat.mFramesPerPacket = 1;
	outFormat.mChannelsPerFrame = 1;	
	outFormat.mBytesPerPacket = (UInt32)bytesPerSample * outFormat.mFramesPerPacket;
	outFormat.mBytesPerFrame = (UInt32)bytesPerSample * outFormat.mChannelsPerFrame;
	outFormat.mSampleRate = 44100;
	
	UInt32 inSize = (UInt32)(capacity*sizeof(SInt16));
	UInt32 outSize = (UInt32)(capacity*sizeof(float));
	err = AudioConverterNew(&audioFormat, &outFormat, &converter);
	err = AudioConverterConvertBuffer(converter, inSize, buf, &outSize, outputBuf);
}

float MagnitudeSquared(float x, float y) 
{
	return ((x*x) + (y*y));
}

-(void)DSPRender:(uint32_t)numFrames Buffer:(AudioBufferList*)ioData
{    
    // Fill the buffer with our sampled data. If we fill our buffer, run the
	// fft.
    int read = (int)(_bufferCapacity - _index);
	if (read > numFrames) 
    {
		memcpy((SInt16 *)_dataBuffer + _index, ioData->mBuffers[0].mData, numFrames*sizeof(SInt16));
		_index += numFrames;
	} 
    else 
    {
		// If we enter this conditional, our buffer will be filled and we should 
		// perform the FFT.
		memcpy((SInt16 *)_dataBuffer + _index, ioData->mBuffers[0].mData, read*sizeof(SInt16));
		
		// Reset the index.
		_index = 0;
		
		// We want to deal with only floating point values here.
		ConvertInt16ToFloat(_audioFormat, _dataBuffer, _outputBuffer, _bufferCapacity);
		vDSP_ctoz((COMPLEX*)_outputBuffer, 2, &_A, 1, _nOver2);
		vDSP_fft_zrip(_fftSetup, &_A, 1, _log2n, FFT_FORWARD);
		vDSP_ztoc(&_A, 1, (COMPLEX *)_outputBuffer, 2, _nOver2);
        
        for (int i=0; i<_outputBufferSize; i+=2) 
            _currentBuffer[i/2] = _currentBuffer[i/2] * 0.75 + sqrtf(MagnitudeSquared(_outputBuffer[i], _outputBuffer[i+1])) * 0.25;
        memset(_outputBuffer, 0, _bufferCapacity *sizeof(float));
	}
}


@end
