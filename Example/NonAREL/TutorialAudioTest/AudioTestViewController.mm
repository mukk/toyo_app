// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "HelloWorldViewController.h"

@interface HelloWorldViewController ()

@end

@implementation HelloWorldViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialHelloWorld/Assets"];
    
	if(trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile UTF8String];
        bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    // load content
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialHelloWorld/Assets"];
    
	if(metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [metaioManModel UTF8String];
        metaio::IGeometry* theLoadedModel =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if( theLoadedModel )
        {
            // scale it a bit up
            theLoadedModel->setScale(4.f);
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);
        }
    }
}

@end
