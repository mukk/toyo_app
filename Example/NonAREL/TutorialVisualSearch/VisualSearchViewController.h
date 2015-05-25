// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"
#import <metaioSDK/IVisualSearchCallback.h>

@interface VisualSearchViewController : NonARELTutorialViewController
{
    metaio::IGeometry* m_model;
    bool m_vsRequested;
    metaio::TrackingValues m_trackingValues;
    
}

@end
