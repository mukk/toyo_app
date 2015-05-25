// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "DynamicModelsViewController.h"

@interface DynamicModelsViewController ()

@end


@implementation DynamicModelsViewController


#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    
    // load our tracking configuration
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast"
																 ofType:@"xml"
															inDirectory:@"tutorialContent_crossplatform/TutorialDynamicModels/Assets"];
    
    
    // if you want to test the 3D tracking, please uncomment the line below and comment the line above
    //NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_ML3D" ofType:@"xml" inDirectory:@"Tutorials/Tutorial4/Assets4"];	
    
    
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
														  inDirectory:@"tutorialContent_crossplatform/TutorialDynamicModels/Assets"];
    
	if(metaioManModel)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        const char *utf8Path = [metaioManModel UTF8String];
        m_metaioMan =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if( m_metaioMan )
        {
            // scale it a bit up
             m_metaioMan->setScale(4.f);
        }
        else
        {
            NSLog(@"error, could not load %@", metaioManModel);            
        }
    }
    
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

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}

#pragma mark - @protocol MobileDelegate

- (void) onAnimationEnd: (metaio::IGeometry*) geometry  andName:(const NSString*) animationName
{
    // handle the metaio man animations
    if( geometry == m_metaioMan )
    {
        // check the previous animation name and act accordingly
        if( [animationName compare:@"shock_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "shock_idle" , false);
        }
        else if( [animationName compare:@"shock_idle"] == NSOrderedSame  )
        {
            geometry->startAnimation( "shock_up" , false);
        }
        else if((  [animationName compare:@"shock_up"] == NSOrderedSame  ) || ( [animationName compare:@"close_up"] == NSOrderedSame  ) )
        {
            if( m_isCloseToModel )
            {
                geometry->startAnimation( "close_idle", true);
            }
            else
            {
                geometry->startAnimation( "idle", true );
            }
        }
        else if( [animationName compare:@"close_down"] == NSOrderedSame )
        {
            geometry->startAnimation( "close_idle", true);
        }
    }
    
}


#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
	UITouch *touch = [touches anyObject];
	CGPoint loc = [touch locationInView:self.glkView];
	
    // get the scale factor (will be 2 for retina screens)
    float scale = self.glkView.contentScaleFactor;
    
	// ask sdk if the user picked an object
	// the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, true);
	
    if ( model == m_metaioMan)
	{
		// we have touched the metaio man
		// let's start an animation
		model->startAnimation( "shock_down" , false);
	}
}


#pragma mark -
#pragma mark Distance checking


- (void) checkDistanceToTarget
{
	// get the current tracking values for cos 1

    metaio::TrackingValues currentPose = m_pMetaioSDK->getTrackingValues(1);
    
    
	// if the quality value > 0, it means we're currently tracking
	// Note, you can use this mechanism also to detect if something is tracking or not.
	// (e.g. for triggering an action as soon as some target is visible on screen)
	if( currentPose.quality > 0 )
	{
		// get the translation part of the pose
		metaio::Vector3d poseTranslation = currentPose.translation;
		
		// calculate the distance as sqrt( x^2 + y^2 + z^2 )
		float distanceToTarget = sqrt(poseTranslation.x * poseTranslation.x +
									  poseTranslation.y * poseTranslation.y +
									  poseTranslation.z * poseTranslation.z
									  );
		
		// define a threshold distance
		float threshold = 800;
		
		// if we are already close to the model
		if( m_isCloseToModel )
		{
			// if our distance is larger than our threshold (+ a little)
			if( distanceToTarget > (threshold + 10) )
			{
				// we flip this variable again
				m_isCloseToModel = false;
				
				// and start the close_up animation
				m_metaioMan->startAnimation( "close_up" , false);
			}
		}
		else
		{
			// we're not close yet, let's check if we are now
			if( distanceToTarget < threshold )
			{
				// flip the variable
				m_isCloseToModel = true;
				
				// and start an animation
				m_metaioMan->startAnimation( "close_down" , false );
			}
		}
	}
}


- (void)drawFrame
{
    [super drawFrame];
    
    // tell sdk to render
    if( m_pMetaioSDK )
    {
        // only do that, if we're currently viewing the metaio man
        if( m_metaioMan->isVisible() )
        {
            [self checkDistanceToTarget];
        }
    }
}


@end
