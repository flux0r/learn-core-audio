#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/*
 * CD audio is sampled at 44.1 kHz. I'll make a five second audio file of a very
 * simple square wave.
 */
#define SAMPLE_RATE 44100
#define DURATION 5.0
#define FILENAME_FORMAT @"%0.3f-square.aif"

int main(int argc, const char * argv[])
{
	NSAutoreleasePool*pool = [[NSAutoreleasePool alloc] init];
	
	if (argc < 2) {
		printf("Usage: CAToneFileGenerator n\n(where n is tone in Hz)");
		return -1;
	}

	/* The argument is a floating point number for the frequency */
	double hz = atof(argv[1]);
	assert(hz > 0);
	NSLog (@"generating %f hz tone", hz);

	/* 
	 * Create a file name and then make that into a ``NSURL'', since Audio
	 * File Services functions take URLs instead of paths.
	 */
	NSString*fileName = [NSString stringWithFormat: FILENAME_FORMAT, hz];
	NSString*filePath = [
		[[NSFileManager defaultManager] currentDirectoryPath]
		stringByAppendingPathComponent: fileName
		];
	NSURL*fileURL = [NSURL fileURLWithPath: filePath];

	/* 
	 * Create a description for the audio file using an
	 * ``AudioStreamBasicDescription'' and then blank out the fields so Core
	 * Audio will fill in missing ones later, if necessary. Fill in the
	 * description to specify a mono PCM file a data rate of 44,100, 16-bit
	 * samples, and two bytes per frame. Linear PCM doesn't use packets, so
	 * the number of bytes per frame and per packet are the same. AIFF only
	 * uses big-endian PCM. Use the numeric format for signed integers and
	 * indicate packed samples.
	 */
	AudioStreamBasicDescription desc;
	memset(&desc, 0, sizeof(desc));
	desc.mSampleRate = SAMPLE_RATE;
	desc.mFormatID = kAudioFormatLinearPCM;
	desc.mFormatFlags = kAudioFormatFlagIsBigEndian
		| kAudioFormatFlagIsSignedInteger
		| kAudioFormatFlagIsPacked;
	desc.mBitsPerChannel = 16;
	desc.mChannelsPerFrame = 1;
	desc.mFramesPerPacket = 1;
	desc.mBytesPerFrame = 2;
	desc.mBytesPerPacket = 2;

}
