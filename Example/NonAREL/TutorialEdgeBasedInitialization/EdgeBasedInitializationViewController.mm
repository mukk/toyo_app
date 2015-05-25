// Copyright 2007-2014 Metaio GmbH. All rights reserved.
#import "EdgeBasedInitializationViewController.h"

@interface EdgeBasedInitializationViewController ()

@end


@implementation EdgeBasedInitializationViewController



#pragma mark - UIViewController lifecycle


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    mRimModel = [self loadModel:@"tutorialContent_crossplatform/TutorialEdgeBasedInitialization/Assets/Custom/rim.obj"];
    mVizAidModel = [self loadModel:@"tutorialContent_crossplatform/TutorialEdgeBasedInitialization/Assets/Custom/VizAid.obj"];
    
    if (mRimModel)
        mRimModel->setCoordinateSystemID(1);

    if (mVizAidModel)
        mVizAidModel->setCoordinateSystemID(2);
		
    NSString* envmapPath = [[NSBundle mainBundle] pathForResource:@"env_map"
                                                           ofType:@"png"
                                                      inDirectory:@"tutorialContent_crossplatform/TutorialEdgeBasedInitialization/Assets/Custom/"];
    if (envmapPath) {
        const char *utf8Path = [envmapPath UTF8String];
        m_pMetaioSDK->loadEnvironmentMap(metaio::Path::fromUTF8(utf8Path), metaio::EEMF_LATLONG);
    }
    
    [self loadTrackingConfig];
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

-(metaio::IGeometry*)loadModel:(NSString*)path
{
    metaio::IGeometry* geometry = 0;
    // Load model
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:path ofType:@"" inDirectory:@""];
    
    if(modelPath)
    {
        const char *utf8Path = [modelPath UTF8String];
        geometry = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        if(!geometry)
           NSLog(@"No success loading model");
    } else NSLog(@"No success loading model");
        
    return geometry;
}

-(bool)setTrackingConfiguration:(NSString*)path
{
    bool result = false;
    // set tracking configuration
    NSString* xmlPath = [[NSBundle mainBundle] pathForResource:path ofType:@"" inDirectory:@""];
    if (xmlPath)
    {
        const char *utf8Path = [xmlPath UTF8String];
        result = m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8(utf8Path));
        if(!result)
            NSLog(@"No success setting tracking xml");
    } else  NSLog(@"No success setting tracking xml");
    return result;
}

#pragma mark - App Logic
- (void) loadTrackingConfig
{
    [self setTrackingConfiguration:@"tutorialContent_crossplatform/TutorialEdgeBasedInitialization/Assets/Custom/rim_tracking/Tracking.xml"];
}


//      [self loadTrackingConfig];
- (IBAction)onResetPressed:(UIButton*)sender
{
    m_pMetaioSDK->sensorCommand("reset");
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


@end
