// Copyright 2007-2014 metaio GmbH. All rights reserved.
#import "NonARELTutorialViewController.h"

@interface DynamicModelsViewController : NonARELTutorialViewController
{
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
   
    bool                     m_isCloseToModel;     // to keep track if we moved close to the 
}


/** This method is regularly called, calculates the distance between phone and target
 * and performs actions based on the distance 
 */
- (void) checkDistanceToTarget;
@end

