// #import <CoreDuet/_CDBatterySaver.h>
@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (long long)getPowerMode;
- (long long)setMode:(long long)arg1;
@end

static long long last_lpm_state = 0;

static void sb_event_acstatuschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSDictionary *batteryState = (__bridge NSDictionary *) userInfo;
	_CDBatterySaver *batterySaver = [_CDBatterySaver batterySaver];

	if([batteryState[@"IsCharging"] isEqual:@1]
	&& ([batteryState[@"CurrentCapacity"] floatValue] / [batteryState[@"MaxCapacity"] floatValue]) < 0.8) {
		// Enable LPM.
		last_lpm_state = [batterySaver getPowerMode];
		[batterySaver setMode:1];
	} else {
		// Disable LPM if it was disabled before.
		if(last_lpm_state == 0) {
			[batterySaver setMode:0];	
		}
	}
}

static void sb_event_fullycharged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	// Disable LPM if it was disabled before.
	if(last_lpm_state == 0) {
		_CDBatterySaver *batterySaver = [_CDBatterySaver batterySaver];
		[batterySaver setMode:0];	
	}
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

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		sb_event_fullycharged,
		CFSTR("com.apple.springboard.fullycharged"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}
