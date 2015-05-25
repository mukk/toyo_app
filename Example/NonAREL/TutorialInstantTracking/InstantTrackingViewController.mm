// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "InstantTrackingViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface InstantTrackingViewController ()
{
	SystemSoundID catSound;
}
- (void) setActiveTrackingConfig: (int) index;
@end


@implementation InstantTrackingViewController


#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
	[super viewDidLoad];
	m_previewMode = YES;
	m_mustUseInstantTrackingEvent = NO;
	// load content
	NSString* tigerModelPath = [[NSBundle mainBundle] pathForResource:@"tiger"
															   ofType:@"md2"
														  inDirectory:@"tutorialContent_crossplatform/TutorialInstantTracking/Assets"];

	if (tigerModelPath)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D models
		const char *utf8Path = [tigerModelPath UTF8String];
		m_tigerModel =  m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
		if (m_tigerModel)
		{
			m_tigerModel->setScale(8.0f);
			m_tigerModel->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, (float)M_PI)));
		}
		else
		{
			NSLog(@"error, could not load %@", tigerModelPath);
		}
	}

	NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"meow"
														  ofType:@"aif"
													 inDirectory:@"tutorialContent_crossplatform/TutorialInstantTracking/Assets"];
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath: soundPath]), &catSound);
}


- (void)viewDidUnload
{
	m_2DButton = nil;
	m_2DRectifiedButton = nil;
	m_3DButton = nil;
	m_2DSLAMButton = nil;
	m_2DSLAMExtrapolationButton = nil;

	[super viewDidUnload];
}


#pragma mark - App Logic
- (void)setActiveTrackingConfig:(int)index
{
	m_mustUseInstantTrackingEvent = YES;

	switch (index)
	{
		case 0:
		{
			m_pMetaioSDK->startInstantTracking("INSTANT_2D", metaio::Path(), m_previewMode);
			m_2DRectifiedButton.enabled = !m_previewMode;
			m_3DButton.enabled = !m_previewMode;
			m_2DSLAMButton.enabled = !m_previewMode;
			m_2DSLAMExtrapolationButton.enabled = !m_previewMode;
			if (!m_previewMode) dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_2DButton]; });
			else dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:nil]; });
			m_previewMode = !m_previewMode;
			NSLog(@"Instant tracking snapshot is done");
			break;
		}

		case 1:
		{
			m_pMetaioSDK->startInstantTracking("INSTANT_2D_GRAVITY", metaio::Path(), m_previewMode);
			m_2DButton.enabled = !m_previewMode;
			m_3DButton.enabled = !m_previewMode;
			m_2DSLAMButton.enabled = !m_previewMode;
			m_2DSLAMExtrapolationButton.enabled = !m_previewMode;
			if (!m_previewMode) dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_2DRectifiedButton]; });
			else dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:nil]; });
			m_previewMode = !m_previewMode;
			NSLog(@"Instant rectified tracking snapshot is done");
			break;
		}

		case 2:
		{
			m_mustUseInstantTrackingEvent = NO;
			m_pMetaioSDK->startInstantTracking("INSTANT_3D");
			NSLog(@"SLAM started");
			dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_3DButton]; });
			break;
		}

		case 3:
		{
			m_pMetaioSDK->startInstantTracking("INSTANT_2D_GRAVITY_SLAM", metaio::Path(), m_previewMode);
			m_2DButton.enabled = !m_previewMode;
			m_2DRectifiedButton.enabled = !m_previewMode;
			m_3DButton.enabled = !m_previewMode;
			m_2DSLAMExtrapolationButton.enabled = !m_previewMode;
			if (!m_previewMode) dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_2DSLAMButton]; });
			else dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:nil]; });
			m_previewMode = !m_previewMode;
			NSLog(@"Instant tracking snapshot is done");
			break;
		}

		case 4:
		{
			m_pMetaioSDK->startInstantTracking("INSTANT_2D_GRAVITY_SLAM_EXTRAPOLATED", metaio::Path(), m_previewMode);
			m_2DButton.enabled = !m_previewMode;
			m_2DRectifiedButton.enabled = !m_previewMode;
			m_3DButton.enabled = !m_previewMode;
			m_2DSLAMButton.enabled = !m_previewMode;
			if (!m_previewMode) dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:m_2DSLAMExtrapolationButton]; });
			else dispatch_async(dispatch_get_main_queue(), ^{ [self highlightButton:nil]; });
			m_previewMode = !m_previewMode;
			NSLog(@"Instant tracking snapshot is done");
			break;
		}
	}
}


- (void)highlightButton:(UIButton*)button
{
	m_2DButton.highlighted = false;
	m_2DRectifiedButton.highlighted = false;
	m_3DButton.highlighted = false;
	m_2DSLAMButton.highlighted = false;
	m_2DSLAMExtrapolationButton.highlighted = false;

	if (button)
	{
		button.highlighted = true;
	}
}


- (void)onSDKReady
{
	[super onSDKReady];

	m_2DButton.hidden = false;
	m_2DRectifiedButton.hidden = false;
	m_3DButton.hidden = false;
	m_2DSLAMButton.hidden = false;
	m_2DSLAMExtrapolationButton.hidden = false;
}


- (IBAction)on2DButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:0];
}


- (IBAction)on2DRectifiedButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:1];
}


- (IBAction)on3DButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:2];
}


- (IBAction)on2DSLAMButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:3];
}


- (IBAction)on2DSLAMExtrapolationButtonClicked:(UIButton*)sender
{
	[self setActiveTrackingConfig:4];
}


- (void) onInstantTrackingEvent:(bool)success file:(const NSString*) filepath
{
	// load the tacking configuration
	if (success)
	{
		// Since SDK 6.0, INSTANT_3D doesn't create a new tracking configuration anymore
		// (see changelog)
		if (m_mustUseInstantTrackingEvent)
		{
			m_pMetaioSDK->setTrackingConfiguration(metaio::Path::fromUTF8([filepath UTF8String]));
		}
	}
	else
	{
		NSLog(@"SLAM has timed out!");
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
	if (currentPose.quality > 0)
	{
		// get the translation part of the pose
		metaio::Vector3d poseTranslation = currentPose.translation;

		// calculate the distance as sqrt( x^2 + y^2 + z^2 )
		float distanceToTarget = sqrt(poseTranslation.x * poseTranslation.x +
									  poseTranslation.y * poseTranslation.y +
									  poseTranslation.z * poseTranslation.z
									  );

		// define a threshold distance
		float threshold = 250;

		// if we are already close to the model
		if (m_isCloseToModel)
		{
			// if our distance is larger than our threshold (+ a little)
			if (distanceToTarget > threshold + 10)
			{
				// we flip this variable again
				m_isCloseToModel = false;

				// play sound
				AudioServicesPlaySystemSound(catSound);
				m_tigerModel->startAnimation("tap", false);
			}
		}
		else
		{
			// we're not close yet, let's check if we are now
			if (distanceToTarget < threshold)
			{
				// flip the variable
				m_isCloseToModel = true;

				//play sound again
				AudioServicesPlaySystemSound(catSound);
				m_tigerModel->startAnimation("tap", false);
			}
		}
	}
}

- (void)drawFrame
{
	[super drawFrame];

	// tell sdk to render
	if (m_pMetaioSDK)
	{
		// only do that, if we're currently viewing the metaio man
		if (m_tigerModel->isVisible())
		{
			[self checkDistanceToTarget];
		}
	}
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	// allow rotation in all directions
	return YES;
}


@end
