//
//  Min.m
//  Min
//
//  Created by Clay Bridges on 9/20/10.
//  Copyright 2010 change machine. All rights reserved.
//

#import "Min.h"

@implementation Min

+ (NSString *)yo {
	return @"'Sup. I'm the Min framework.";
}

@end

void MinInit() {
	static uint initialized = 0;
	if (!initialized) {
		initialized = 1;
	}
}