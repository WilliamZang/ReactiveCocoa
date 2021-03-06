//
//  UITableViewCell+RACSignalSupport.m
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2013-07-22.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import "UITableViewCell+RACSignalSupport.h"
#import "NSObject+RACDescription.h"
#import "NSObject+RACSelectorSignal.h"
#import "RACSignal+Operations.h"
#import "RACUnit.h"
#import <objc/runtime.h>

@implementation UITableViewCell (RACSignalSupport)

- (RACSignal *)rac_prepareForReuseSignal {
	RACSignal *signal = objc_getAssociatedObject(self, _cmd);
	if (signal != nil) return signal;

	signal = [[[self
		rac_signalForSelector:@selector(prepareForReuse)]
		mapReplace:RACUnit.defaultUnit]
		setNameWithFormat:@"%@ -rac_prepareForReuseSignal", RACDescription(self)];
	
	objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return signal;
}

@end

@interface RACSubscriptingAssignmentTrampoline (SAKSubscriptingAssignmentTrampolineForCell)

// The object to bind to.
@property (nonatomic, strong, readonly) id target;

// A value to use when `nil` is sent on the bound signal.
@property (nonatomic, strong, readonly) id nilValue;

@end

@implementation SAKSubscriptingAssignmentTrampolineForCell

- (void)setObject:(RACSignal *)signal forKeyedSubscript:(NSString *)keyPath {
	NSCAssert1([self.target isKindOfClass:[UITableViewCell class]], @"%@ should be kind of UITableViewCell", self.target);
	
	[super setObject:[signal takeUntil:[(UITableViewCell *)self.target rac_prepareForReuseSignal]] forKeyedSubscript:keyPath];
}

@end
