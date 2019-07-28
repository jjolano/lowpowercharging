// #import <CoreDuet/_CDBatterySaver.h>
@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (int)getPowerMode;
- (int)setMode:(int)arg1;
@end

static int last_lpm_state = 0;

static void set_lpm(void) {
	// Check if device is charging.
	UIDeviceBatteryState state = [[UIDevice currentDevice] batteryState];
	_CDBatterySaver *batterySaver = [_CDBatterySaver batterySaver];

	if(state == UIDeviceBatteryStateUnplugged) {
		// Disable LPM if it was disabled before.
		if(last_lpm_state == 0) {
			[batterySaver setMode:0];	
		}
	}

	if(state == UIDeviceBatteryStateCharging) {
		// Enable LPM.
		last_lpm_state = [batterySaver getPowerMode];
		[batterySaver setMode:1];
	}
}

static void sb_event_acstatuschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	set_lpm();
}

%ctor {
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		NULL,
		sb_event_acstatuschanged,
		CFSTR("SBUIACStatusChangedNotification"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}
