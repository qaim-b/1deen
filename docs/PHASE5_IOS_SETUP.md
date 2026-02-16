# Phase 5 iOS setup (Screen Time stack)

This repo now includes iOS Screen Time source scaffolds:
- `ios/DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift`
- `ios/ShieldConfigurationExtension/ShieldConfigurationExtension.swift`
- entitlements files for Runner and both extensions

Because this machine is Windows, final iOS target wiring must be done in Xcode on macOS.

## Xcode wiring steps

1. Open `ios/Runner.xcworkspace` in Xcode.
2. Add target: `Device Activity Monitor Extension`.
3. Add target: `Shield Configuration Extension`.
4. For the monitor extension target:
   - Replace generated Swift file with `ios/DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.swift`.
   - Replace Info.plist with `ios/DeviceActivityMonitorExtension/Info.plist`.
   - Set entitlements file to `ios/DeviceActivityMonitorExtension/DeviceActivityMonitorExtension.entitlements`.
5. For the shield extension target:
   - Replace generated Swift file with `ios/ShieldConfigurationExtension/ShieldConfigurationExtension.swift`.
   - Replace Info.plist with `ios/ShieldConfigurationExtension/Info.plist`.
   - Set entitlements file to `ios/ShieldConfigurationExtension/ShieldConfigurationExtension.entitlements`.
6. Runner target:
   - Ensure `Signing & Capabilities` includes:
     - `Family Controls`
     - `App Groups` with `group.com.example.app.onedeen`
   - `Runner.entitlements` is already referenced in project build settings.
7. Set extension bundle ids:
   - `com.example.app.DeviceActivityMonitorExtension`
   - `com.example.app.ShieldConfigurationExtension`
8. Build and run on a physical iPhone (iOS 16+).

## Runtime checks

1. Trigger auth from app startup (already called by automation): `requestIosAuthorization`.
2. Confirm iOS permission prompt appears and is approved.
3. Sync prayer windows from Flutter.
4. Wait for next window start and verify shield appears.
5. Verify shield clears when window ends.
