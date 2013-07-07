/******************************************************************
 *  EasyTransfer Arduino Library (iOS Redpark port)
 *    details and example sketch:
 *    http://www.billporter.info/easytransfer-arduino-library/
 *
 *    Originally brought to you by:
 *              Bill Porter
 *              www.billporter.info
 *
 *    Ported to iOS by:
 *              Hok Shun Poon
 *              www.hokshunpoon.me
 *
 *    See Readme for other info and version history
 *
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or(at your option) any later version.
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 <http://www.gnu.org/licenses/>
 *
 * This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
 * To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ or
 * send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
 ******************************************************************/

#define details(name) (byte *)&name, sizeof(name)

#import <RscMgr.h>
#import <math.h>
#import <stdio.h>
#import <stdint.h>

@interface ArduinoEasyTransfer : NSObject {
    uint8_t objSize;      // size of the message being transferred
    uint8_t *rx_buffer;   // address for temporary storage and parsing buffer
    uint8_t rx_array_inx; // index for RX parsing buffer
    uint8_t rx_len;       // RX packet length according to the packet
    uint8_t calc_CS;      // calculated Chacksum
};

// the message size is encapsulated in the initialisation method for convenience
// to mimic the syntax of the Arduino EasyTransfer Library
- (id)initWithSize:(UInt8)size;

- (void)sendDataWith:(RscMgr *)redpark bytes:(UInt8 *)addr;

- (BOOL)receiveDataFrom:(RscMgr *)redpark into:(UInt8 *)addr;

+ (NSData *)makeFrame:(UInt8 *)addr ofSize:(size_t)size;
@end
