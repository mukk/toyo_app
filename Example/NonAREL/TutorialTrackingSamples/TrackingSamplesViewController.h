// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface TrackingSamplesViewController : NonARELTutorialViewController
{
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
    NSString *trackingConfigFile;
}

@property (weak, nonatomic) IBOutlet UIButton* button_idMarker;
@property (weak, nonatomic) IBOutlet UIButton* button_picture;
@property (weak, nonatomic) IBOutlet UIButton* button_markerless;

- (IBAction)onIDMarkerButtonClicked:(UIButton*)sender;
- (IBAction)onPictureButtonClicked:(UIButton*)sender;
- (IBAction)onMarkerlessButtonClicked:(UIButton*)sender;

@end

