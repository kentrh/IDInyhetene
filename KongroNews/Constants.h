//
//  Constants.h
//  KongroNews
//
//  Created by Kent Robin Haugen on 24.02.13.
//  Copyright (c) 2013 Kent Robin Haugen. All rights reserved.
//

#ifndef KongroNews_Constants_h
#define KongroNews_Constants_h

#define NUMBER_OF_BACKGROUND_IMAGES 12

#define USER_DEFAULTS_PREVIOUS_ARTICLE @"previousArticle"

#define CATEGORY_TAG_FAVORITES -1
#define CATEGORY_TAG_TOP_STORIES 1

#define ANIMATION_DURATION 1.0f
#define ANIMATION_NUMBER_OF_BOUNCES 3
#define ANIMATION_SHOULD_OVERSHOOT 1

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define BUTTON_HEIGHT 80.0f
#define BUTTON_Y 20.0f
#define BUTTON_X 20.0f
#define BUTTON_VERTICAL_SPACING 20.0f
#define BUTTON_FONT_TYPE @"AmericanTypewriter"
#define BUTTON_FONT_SIZE 14.0f

#endif
