// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"
#import <metaioSDK/GestureHandlerIOS.h>

@interface InteractiveFurnitureViewController : NonARELTutorialViewController
{
    // pointers to geometries
    metaio::IGeometry* m_metaioMan; 
    metaio::IGeometry* m_chair; 
    metaio::IGeometry* m_tv;
    metaio::IGeometry* m_screen;
    // GestureHandler handles the dragging/pinch/rotation touches
    GestureHandlerIOS* m_gestureHandler;
    //gesture mask to specify the gestures that are enabled
    int m_gestures;
    //indicate if a camera image has been requested from the user
    NSString* m_imageTaken;
    // indicate if the image buttons can be clicked
    bool m_buttonEnabled;
	// remember the TrackingValues
	metaio::TrackingValues m_pose;

	__weak IBOutlet UIButton* m_tvButton;
	__weak IBOutlet UIButton* m_chairButton;
	__weak IBOutlet UIButton* m_manButton;

	__weak IBOutlet UIButton* m_takePictureButton;
	__weak IBOutlet UIButton* m_saveScreenButton;
	__weak IBOutlet UIButton* m_resetButton;
}
//geometry button callback to show/hide the geometry and reset the location and scale of the geometry
- (IBAction)onTVButtonClick:(id)sender;
- (IBAction)onChairButtonClick:(id)sender;
- (IBAction)onManButtonClick:(id)sender;

// handle buttom buttons
- (IBAction)onTakePicture:(id)sender;
- (IBAction)onSaveScreen:(id)sender;
- (IBAction)onClearScreen:(id)sender;

//show/hide the geometries
- (void)setVisibleTV:(bool)visible;
- (void)setVisibleChair:(bool)visible;
- (void)setVisibleMan:(bool)visible;
@end


