iOS Port of the EasyTransfer Arduino Library
--------------------------------------------

Easy serial communications between [iOS devices][3] and [Arduinos][4] via a
[RedPark serial cable][5].

While RedPark provides an SDK for using their cables for serial communications,
it exposes a very primitive interface for sending and receiving bytes.

By porting [Bill Porter's EasyTransfer Arduino Library][2], which originally
was Arduino-to-Arduino communications only, to the iOS, we are now able to
transfer structured data (namely C-structs) between the iOS device and the
Arduino with very few lines of code.

### Getting started

To use, just copy `ArduinoEasyTransfer.{h,m}` into your project and make sure
that `ArduinoEasyTransfer.m` has been the application/library target's `Compile
Sources`.

#### Declare C-structs wire format

These structs should be accessible from the Objective-C code as well as Arduino code,
so it's convenient to stick them all in one header file. Let's call it `data.h`.

```objc
// data.h

struct XYCoordinates {
  int x;
  int y;
};

struct iDeviceToArduino {
  int foo;
  float bar;
  char quux;
  struct XYCoordinates coords;
};

struct ArduinoToIDevice {
  int x;
  int y;
}
```

#### Create instances of ArduinoEasyTransfer

Let's say we've define a class `Foobar` that handles serial communications.  To
handle events from the Redpark cable it must conform to the `RscMgrDelegate`
protocol:

```objc
// Foobar.h

@interface Foobar : NSObject <RscMgrDelegate> {
  RscMgr *rscMgr;
  ArduinoEasyTransfer *txTransfer;
  ArduinoEasyTransfer *rxTransfer;
}
...
@end
```

You'll want to initialise these the following way:

```objc
// Foobar.m

#import "ArduinoEasyTransfer.h"
#import "RscMgr.h"
#import "data.h"

@implementation Foobar

-(id)init {
  if(self = [super init]) {
    rscMgr = [[RscMgr alloc] init];
    [rscMgr setDelegate:self];
    txTransfer = [[ArduinoEasyTransfer alloc] initWithSize:sizeof(typeof(struct iDeviceToArduino))];
    rxTransfer = [[ArduinoEasyTransfer alloc] initWithSize:sizeof(typeof(struct ArduinoToIDevice))];
  }
  return self;
}

...

@end
```

#### Sending data

```objc
// Foobar.m

  ...
  struct iDeviceToArduino txMessage = { 1, 2.0f, 'c', {10,20}};
  [txTransfer sendDataWith:rscMgr bytes:(void *)txMessage];
  ...
```

#### Receiving data

Just implement `readBytesAvailable:` so that we're told about any incoming
data. We use EasyTransfer to make sense of it:

```objc
// Foobar.m

- (void)readBytesAvailable:(UInt32)numBytes {
  ...
  struct iDeviceToArduino rxMessage;
  ...
  while ([easyTransfer receiveDataFrom:rscMgr into:(void *)&rxMessage]) {
    // do something with rxMessage...
  }
  ...
}
```

#### Sending and receiving data on the Arduino side

Follow the code examples on [EasyTransfer's home page][2].

### In case of trouble...

No worries, just [file an issue on GitHub][5]. Better still, find out the issue
and submit a pull request.

### License

[The MIT License (MIT)][6]

[1]: http://www.redpark.com/c2ttl.html
[2]: http://www.billporter.info/2011/05/30/easytransfer-arduino-library/
[3]: http://en.wikipedia.org/wiki/IDevice
[4]: http://www.redpark.com/products.html
[5]: https://github.com/fatuhoku/iOS-EasyTransfer-Arduino/issues
[6]: http://pankaj.mit-license.org/
