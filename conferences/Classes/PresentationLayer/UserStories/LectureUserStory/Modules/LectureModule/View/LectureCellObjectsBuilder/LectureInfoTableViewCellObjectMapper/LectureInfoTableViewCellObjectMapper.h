//
//  LectureInfoTableViewCellObjectMapper.h
//  Conferences
//
//  Created by k.zinovyev on 01.12.16.
//  Copyright © 2016 Rambler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Nimbus/NimbusModels.h>

@class LectureViewModel;
@class LectureInfoTableViewCellCalculator;

@interface LectureInfoTableViewCellObjectMapper : NSObject

@property (nonatomic, strong) LectureInfoTableViewCellCalculator *calculator;
 
- (id<NICellObject>)lectureInfoTableViewCellObjectWithLecture:(LectureViewModel *)lecture
                                          continueReadingFlag:(BOOL)continueReadingFlag;
@end
