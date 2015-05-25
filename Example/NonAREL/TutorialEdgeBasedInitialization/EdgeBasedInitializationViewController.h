// Copyright 2007-2014 Metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface EdgeBasedInitializationViewController : NonARELTutorialViewController
{

    metaio::IGeometry* mRimModel;
	metaio::IGeometry* mVizAidModel;
}

/* Handle segment control */
- (IBAction)onResetPressed:(UIButton*)sender;

-(metaio::IGeometry*)loadModel:(NSString*)path;
-(bool)setTrackingConfiguration:(NSString*)path;

@end

