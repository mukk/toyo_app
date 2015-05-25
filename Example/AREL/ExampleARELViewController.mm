// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "ExampleARELViewController.h"

@implementation ExampleARELViewController

- (IBAction)onCloseButtonClicked:(UIButton*)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - IARELInterpreterIOSDelegate


- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
	// Override to handle "saved to gallery" event
}


- (bool)shareScreenshot:(UIImage*)image options:(bool)saveToGalleryWithoutDialog
{
	if (saveToGalleryWithoutDialog)
	{
		dispatch_async(dispatch_get_global_queue(0, 0), ^(void) {
			dispatch_async(dispatch_get_main_queue(), ^(void) {
				UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
			});
		});

		// Return true to state that we're handling this event
		return true;
	}
	else
	{
		// Open a share controller with the image
		NSLog(@"Implement your sharing controller here.");

		return false;
	}
}


@end
