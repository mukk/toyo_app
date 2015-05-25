// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "QRCodeReaderViewController.h"

@interface QRCodeReaderViewController ()

//ensure only one alert is shown at the same time
@property (nonatomic, strong) UIAlertView *alertView;

@end

@implementation QRCodeReaderViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
	
	self.alertView = nil;
	
    bool success = m_pMetaioSDK->setTrackingConfiguration("QRCODE");
    if( !success)
        NSLog(@"No success loading the tracking configuration");
}

- (void) onTrackingEvent: (const metaio::stlcompat::Vector<metaio::TrackingValues>&) trackingValues
{
    for (int i = 0; i < trackingValues.size(); i++)
    {
        metaio::TrackingValues tv = trackingValues[i];
        if (tv.isTrackingState())
        {
            NSString* values = [NSString stringWithUTF8String:tv.additionalValues.c_str()];
            NSArray* list = [values componentsSeparatedByString:@"::"];
            if (list.count > 1) {
				if (![self.alertView.message isEqualToString:list[1]] || !self.alertView.isVisible) {
					if (!self.alertView) {
						self.alertView = [[UIAlertView alloc] initWithTitle:@"Scanned QR-Code"
																	message:list[1]
																   delegate:nil
														  cancelButtonTitle:@"OK"
														  otherButtonTitles:nil];
					} else {
						[self.alertView dismissWithClickedButtonIndex:0 animated:NO];
						self.alertView.message = list[1];
					}
					[self.alertView show];
				}
			}
			
		}
	}
}

@end
