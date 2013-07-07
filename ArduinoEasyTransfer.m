#import "ArduinoEasyTransfer.h"
#import "RscMgr.h"

@implementation ArduinoEasyTransfer

- (id)initWithSize:(UInt8)size {
    if (self = [super init]) {
        objSize = size;
        rx_buffer = (uint8_t *) malloc(size);
    }
    return self;
}

- (void)sendDataWith:(RscMgr *)redpark bytes:(UInt8 *)addr {
    NSData *data = [[self class] makeFrame:addr ofSize:objSize];
    [redpark writeData:data];
}

+ (NSData *)makeFrame:(UInt8 *)addr ofSize:(size_t)size {
    NSMutableData *data = [[NSMutableData alloc] init];

    uint8_t CS = size;
    uint8_t headerAndSize[] = {0x06, 0x85, size};
    [data appendBytes:headerAndSize length:3];
    for (int i = 0; i < size; i++) {
        CS ^= *(addr + i);
    }
    [data appendBytes:addr length:size];
    [data appendBytes:&CS length:1];
    return data;
}

- (BOOL)receiveDataFrom:(RscMgr *)redpark into:(UInt8 *)addr {
    uint8_t byte;

    // start off by looking for the header bytes. If they were already found in a previous call, skip it.
    if (rx_len == 0) {
        // this size check may be redundant due to the size check below, but for now I'll leave it the way it is.
        if ([redpark getReadBytesAvailable] >= 3) {

            while ([redpark read:&byte length:1], byte != 0x06) {
                // This will trash any preamble junk in the serial buffer
                // but we need to make sure there is enough in the buffer to process while we trash the rest
                // if the buffer becomes too empty, we will escape and try again on the next call
                if ([redpark getReadBytesAvailable] < 3) {
                    return false;
                }
            }

            if ([redpark read:&byte length:1], byte == 0x85) {
                [redpark read:&byte length:1];
                rx_len = byte;
                if (rx_len != objSize) {
                    rx_len = 0;
                    return false;
                }
            }
        }
    }

    // we get here only when we've already found the header bytes, the struct
    // size matched what we were expecting, and now we are byte aligned.
    if (rx_len != 0) {
        while ([redpark getReadBytesAvailable] && rx_array_inx <= rx_len) {
            [redpark read:&byte length:1];
            rx_buffer[rx_array_inx++] = byte;
        }

        if (rx_len == (rx_array_inx - 1)) {
            // we seem to have got whole message
            //last uint8_t is CS
            calc_CS = rx_len;
            for (int i = 0; i < rx_len; i++) {
                calc_CS ^= rx_buffer[i];
            }

            if (calc_CS == rx_buffer[rx_array_inx - 1]) { //CS good
                memcpy(addr, rx_buffer, objSize);
                rx_len = 0;
                rx_array_inx = 0;
                return true;
            } else {
                //failed checksum, need to clear this out anyway
                rx_len = 0;
                rx_array_inx = 0;
                return false;
            }
        }
    }

    return false;
}

@end
