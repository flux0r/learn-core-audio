#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

/* Open a file, allocate a buffer for the metadata, and get the metadata. */
int main(int argc, const char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	/* Check for file path in arguments. */
	if (argc < 2) {
		printf("Usage: CAMetadata /full/path/to/audiofile\n");
		return -1;
	}

	/* 
	 * Convert to NSString/CFStringRef with UTF-8 encoding and expand tilde
	 * in file path.
	 */
	NSString *audioFilePath = [[NSString stringWithUTF8String:argv[1]]
					stringByExpandingTildeInPath];

	/* Audio File APIs work with URL representations of file paths. */
	NSURL *audioURL = [NSURL fileURLWithPath:audioFilePath];

	/* 
	 * Core Audio uses the AudioFileID type to refer to audio file objects.
	 */
	AudioFileID audioFile;

	/* Core Audio return type. Check on every Core Audio call. */
	OSStatus theErr = noErr;
	theErr = AudioFileOpenURL((CFURLRef) audioURL, kAudioFileReadPermission,
			0, &audioFile);
	assert (theErr == noErr);

	/* Allocate memory for the return file metadata. */
	UInt32 dictionarySize = 0;
	theErr = AudioFileGetPropertyInfo (audioFile,
			kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
	assert (theErr == noErr);

	/* Get the file info dictionary. */
	CFDictionaryRef dictionary;
	theErr = AudioFileGetProperty (audioFile,
			kAudioFilePropertyInfoDictionary, &dictionarySize, &dictionary);
	assert (theErr == noErr);

	/* 
	 * Use "%@" in a format string to get a string representation of the
	 * dictionary, just like with any other Core Foundation or Cocoa object.
	 */
	NSLog (@"dictionary: %@", dictionary);

	/* Release resources. */
	CFRelease (dictionary);
	theErr = AudioFileClose (audioFile);
	assert (theErr == noErr);

	[pool drain];
	return 0;
}
