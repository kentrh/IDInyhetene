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
#define USER_DEFAULTS_STARRED_ARTICLES @"starredArticles"
#define USER_DEFAULTS_PREVIOUS_LOCATION @"previousLocation"
#define USER_DEFAULTS_NEWS_READING_EVENT_QUEUE @"eventQueue"

#define CATEGORY_RELEVANT_NEWS @"Anbefalte"
#define CATEGORY_FAVORITE_NEWS @"Favoritter"

#define ANIMATION_DURATION 1.0f
#define ANIMATION_NUMBER_OF_BOUNCES 3
#define ANIMATION_SHOULD_OVERSHOOT 1

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define BUTTON_HEIGHT 70.0f
#define BUTTON_Y 20.0f
#define BUTTON_X 20.0f
#define BUTTON_VERTICAL_SPACING 20.0f
#define BUTTON_FONT_TYPE @"AmericanTypewriter"
#define BUTTON_FONT_SIZE 14.0f
#define BUTTON_FONT_COUNT_SIZE 10.0f

#define NUMBER_OF_GRADIENTS 5;

#define JSON_USER_PROFILE_USER_ID @"userId"
#define JSON_USER_PROFILE_CATEGORY_INTERESTS @"categoryWeights"
#define JSON_USER_PROFILE_CONTENT_INTERESTS @"contentWeights"
#define JSON_USER_PROFILE_CATEGORY_INTEREST_WEIGHT @"rankByCategoryInterestsWeight"
#define JSON_USER_PROFILE_CONTENT_INTEREST_WEIGHT @"rankByContentInterestsWeight"
#define JSON_USER_PROFILE_FRESHNESS_WEIGHT @"rankByFreshnessWeight"
#define JSON_USER_PROFILE_GEO_DISTANCE_WEIGHT @"rankByGeoDistanceWeight"

#endif
