// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "TrackingSamplesViewController.h"

@interface TrackingSamplesViewController ()
- (void) setActiveTrackingConfig: (int) index;
@end


@implementation TrackingSamplesViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Add Multiple References Tracking
    // load our tracking configuration
    trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
														 ofType:@"xml"
													inDirectory:@"tutorialContent_crossplatform/TutorialTrackingSamples/Assets"];
    
	if(trackingConfigFile)
	{
        const char *utf8Path = [trackingConfigFile UTF8String];
		bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    // load content
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialTrackingSamples/Assets"];
    
	if(metaioManModel)
	{
        // if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [metaioManModel UTF8String];
        m_metaioMan =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if( m_metaioMan )
        {
            // scale it
            m_metaioMan->setScale(4.f);
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);
        }
    }
    
  
    // start with markerless tracking
    [self setActiveTrackingConfig:2];
}



- (void)viewWillAppear:(BOOL)animated
{	
    [super viewWillAppear:animated];
}



- (void) viewDidAppear:(BOOL)animated
{	
	[super viewDidAppear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];	
}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [super viewDidUnload];
}


#pragma mark - App Logic


- (void)highlightButton:(UIButton*)button
{
	_button_idMarker.highlighted = NO;
	_button_picture.highlighted = NO;
	_button_markerless.highlighted = NO;

	button.highlighted = YES;
}


- (void)onSDKReady
{
	[super onSDKReady];

	_button_idMarker.hidden = NO;
	_button_picture.hidden = NO;
	_button_markerless.hidden = NO;
}


- (IBAction)onIDMarkerButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:0];
}


- (IBAction)onPictureButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:1];
}


- (IBAction)onMarkerlessButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:2];
}


- (void) setActiveTrackingConfig:(int)index
{
    switch (index)
    {
        case 0:
		{
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_Marker"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialTrackingSamples/Assets"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(2.0f,2.0f,2.0f));
                const char *utf8Path = [trackingConfigFile UTF8String];
                bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }

			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:_button_idMarker]; });
            break;
		}

        case 1:
		{
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_PictureMarker"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialTrackingSamples/Assets"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(8.0f,8.0f,8.0f));
                const char *utf8Path = [trackingConfigFile UTF8String];
                bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }

			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:_button_picture]; });
            break;
		}

        case 2:
		{
            trackingConfigFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialTrackingSamples/Assets"];
            
            if(trackingConfigFile)
            {
                m_metaioMan->setScale(metaio::Vector3d(4.0f,4.0f,4.0f));
                const char *utf8Path = [trackingConfigFile UTF8String];
                bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
                if( !success)
                    NSLog(@"No success loading the tracking configuration");
            }

			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:_button_markerless]; });
            break;
		}
    }
}

- (void)drawFrame
{
    [super drawFrame];
    
    // return if the metaio SDK has not been initialized yet
    if( !m_pMetaioSDK )
        return;
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}


- (void) onTrackingEvent: (const metaio::stlcompat::Vector<metaio::TrackingValues>&) trackingValues
{
    for (int i = 0; i < trackingValues.size(); i++)
    {
        metaio::TrackingValues tv = trackingValues[i];
        if (tv.isTrackingState())
        {   //if we have detected one, attach our metaioman to this coordinate system ID
            m_metaioMan->setCoordinateSystemID( tv.coordinateSystemID );
        }
    }
}


@end
