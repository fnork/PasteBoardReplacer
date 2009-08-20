#import <Foundation/Foundation.h>
#import <Foundation/NSRange.h>
#import <AppKit/NSPasteboard.h>


static void monitorClipboard(NSString* const target, NSString* const replacement, int interval)
{
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];

	int targetLength = [target length];
	int lastChange = -1;
	NSString *lastString = nil;
	
	while (true) {
		usleep(interval);

		int currentChange = [pboard changeCount];		
		if (lastChange == currentChange)
			continue;
		lastChange = currentChange;
		
		NSString *stringContent = [pboard stringForType:NSStringPboardType];
		int contentLength = [stringContent length];
			
		if (contentLength <= targetLength || NSOrderedSame != [stringContent compare:target options:0 range:NSMakeRange(0, targetLength)])
			continue;

		if (lastString && NSOrderedSame == [stringContent compare:lastString])
			continue;
		
		lastString = [NSString stringWithFormat:replacement, stringContent];
		[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
		if (![pboard setString:lastString forType:NSStringPboardType])
			NSLog(@"Failed to set string %@", lastString);
		else
			NSLog(@"Patched string %@", stringContent);
	}	
}

int main (int argc, const char * argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	monitorClipboard(@"http://www.grabup.com/uploads/", @"%@?direct", 250000);

	[pool drain];
    return 0;
}
