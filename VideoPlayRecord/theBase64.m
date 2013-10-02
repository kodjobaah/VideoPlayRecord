//
//  myBase64.m
//  VideoPlayRecord
//
//  Created by Valtech UK on 29/08/2013.
//  Copyright (c) 2013 What am I doing. All rights reserved.
//

#import "theBase64.h"
#include <stdio.h>
#import <opencv2/highgui/cap_ios.h>
#import <Foundation/Foundation.h>



static unsigned char encodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation theBase64

+ (NSString *)theBase64Representation:(const uchar*)input {

	NSUInteger length = sizeof(input);
	NSUInteger oDataLen = (length*4+2)/3;       // output length without padding
	NSUInteger oLen = ((length+2)/3)*4;         // output length including padding
	
    char output[oLen+1]; //+1 for null terminator
	int ip = 0;
	int op = 0;
	while (ip < length) {
		int i0 = input[ip++];
		int i1 = ip < length ? input[ip++] : 0;
		int i2 = ip < length ? input[ip++] : 0;
		int o0 = i0 >> 2;
		int o1 = ((i0 &   3) << 4) | (i1 >> 4);
		int o2 = ((i1 & 0xf) << 2) | (i2 >> 6);
		int o3 = i2 & 0x3F;
		output[op++] = encodingTable[o0];
		output[op++] = encodingTable[o1];
		output[op] = op < oDataLen ? encodingTable[o2] : '='; op++;
		output[op] = op < oDataLen ? encodingTable[o3] : '='; op++;
	}
	output[op++] = '\0'; //c string terminator
   return [NSString stringWithCString:output encoding:NSASCIIStringEncoding];
}
@end
