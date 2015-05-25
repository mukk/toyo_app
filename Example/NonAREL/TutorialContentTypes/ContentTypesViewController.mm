// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "ContentTypesViewController.h"

@interface ContentTypesViewController ()
- (void) setActiveModel: (int) modelIndex;
@end


@implementation ContentTypesViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
	[super viewDidLoad];


	// load our tracking configuration
	NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets"];


	// if you want to test the 3D tracking, please uncomment the line below and comment the line above
	//NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_ML3D" ofType:@"xml" inDirectory:@"Tutorials/TutorialContentTypes/Assets"];


	if(trackingDataFile)
	{
        const char *utf8Path = [trackingDataFile UTF8String];
		bool success = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}



	// load content
	NSString* modelPath = [[NSBundle mainBundle] pathForResource:@"metaioman"
														  ofType:@"md2"
													 inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets"];

	if(modelPath)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [modelPath UTF8String];
		m_metaioMan =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
		if( m_metaioMan )
		{
			// scale it a bit up
			m_metaioMan->setScale(4.f);
		}
		else
		{
			NSLog(@"error, could not load %@", modelPath);
		}
	}


	// loadimage

	NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"frame"
														  ofType:@"png"
													 inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets"];

	if (imagePath)
	{
        const char *utf8Path = [imagePath UTF8String];
		m_imagePlane = m_pMetaioSDK->createGeometryFromImage(metaio::Path::fromUTF8(utf8Path));
		if (m_imagePlane) {
			m_imagePlane->setScale(metaio::Vector3d(3.0f,3.0f,3.0f));
		}
		else NSLog(@"Error: could not load image plane");
	}

	// load the movie plane
	NSString* moviePath = [[NSBundle mainBundle] pathForResource:@"demo_movie"
														  ofType:@"3g2"
													 inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets"];

	if(moviePath)
	{
        const char *utf8Path = [moviePath UTF8String];
		m_moviePlane =  m_pMetaioSDK->createGeometryFromMovie(metaio::Path::fromUTF8(utf8Path), true); // true for transparent movie
		if( m_moviePlane)
		{
			m_moviePlane->setScale(2.f);
			m_moviePlane->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, -M_PI_2)));

		}
		else
		{
			NSLog(@"Error: could not load movie planes");
		}
	}

	//load the truck model
	NSString* truckPath = [[NSBundle mainBundle] pathForResource:@"truck"
														  ofType:@"obj"
													 inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets/truck"];

	if (truckPath)
	{
        const char *utf8Path = [truckPath UTF8String];
		m_truck = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
		if (m_truck)
		{
			m_truck->setScale(2.f);
			m_truck->setRotation(metaio::Rotation(metaio::Vector3d(M_PI_2, 0, M_PI)));
		}
		else {
			NSLog(@"Error: could not load truck model");
		}
	}

	// Load environment map
	NSString* mapPath = [[NSBundle mainBundle] pathForResource:@"env_map"
														ofType:@"png"
												   inDirectory:@"tutorialContent_crossplatform/TutorialContentTypes/Assets"];

	if (mapPath)
	{
        const char *utf8Path = [mapPath UTF8String];
		Boolean loaded = m_pMetaioSDK->loadEnvironmentMap(metaio::Path::fromUTF8(utf8Path));
		NSLog(@"The environment maps have been loaded: %d", (int)loaded);

	}
	else
	{
		NSLog(@"Error: The filepath for the environment maps is invalid");
	}



	// start with metaio man
	[self setActiveModel:0];
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
	m_modelButton = nil;
	m_imageButton = nil;
	m_truckButton = nil;
	m_movieButton = nil;

	[super viewDidUnload];
}


#pragma mark - App Logic


- (void)onTrackingEvent:(const metaio::stlcompat::Vector<metaio::TrackingValues>&)trackingValues
{
	// We only have one COS, so there can only ever be one TrackingValues structure passed. Play
	// movie if the movie button was selected and we're currently tracking.
	if (trackingValues.empty() || !trackingValues[0].isTrackingState())
	{
		if (m_moviePlane)
			m_moviePlane->pauseMovieTexture();
	}
	else
	{
		if (m_moviePlane && m_selectedModel == 3)
			m_moviePlane->startMovieTexture(true);
	}
}


- (void)setActiveModel:(int)modelIndex
{
	m_selectedModel = modelIndex;

	switch (modelIndex)
	{
		case 0:
		{
			m_imagePlane->setVisible(false);
			m_metaioMan->setVisible(true);
			m_truck->setVisible(false);

			// stop the movie
			m_moviePlane->setVisible(false);
			m_moviePlane->stopMovieTexture();
			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_modelButton]; });
			break;
		}

		case 1:
		{
			m_imagePlane->setVisible(true);
			m_metaioMan->setVisible(false);
			m_truck->setVisible(false);

			// stop the movie
			m_moviePlane->setVisible(false);
			m_moviePlane->stopMovieTexture();
			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_imageButton]; });
			break;
		}

		case 2:
		{
			m_imagePlane->setVisible(false);
			m_metaioMan->setVisible(false);
			m_truck->setVisible(true);

			m_moviePlane->setVisible(false);
			m_moviePlane->stopMovieTexture();
			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_truckButton]; });
			break;
		}

		case 3:
		{
			m_imagePlane->setVisible(false);
			m_metaioMan->setVisible(false);
			m_truck->setVisible(false);

			m_moviePlane->setVisible(true);

			// Start or pause movie according to tracking state
			[self onTrackingEvent:m_pMetaioSDK->getTrackingValues()];

			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_movieButton]; });
			break;
		}
	}
}


- (void)highlightButton:(UIButton*)button
{
	m_modelButton.highlighted = NO;
	m_imageButton.highlighted = NO;
	m_truckButton.highlighted = NO;
	m_movieButton.highlighted = NO;

	button.highlighted = YES;
}


- (void)onSDKReady
{
	[super onSDKReady];

	m_modelButton.hidden = NO;
	m_imageButton.hidden = NO;
	m_truckButton.hidden = NO;
	m_movieButton.hidden = NO;
}


- (IBAction)onModelButtonClicked:(UIButton*)sender
{
	[self setActiveModel:0];
}


- (IBAction)onImageButtonClicked:(UIButton*)sender
{
	[self setActiveModel:1];
}


- (IBAction)onTruckButtonClicked:(UIButton*)sender
{
	[self setActiveModel:2];
}


- (IBAction)onMovieButtonClicked:(UIButton*)sender
{
	[self setActiveModel:3];
}


#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// allow rotation in all directions
	return YES;
}

@end
