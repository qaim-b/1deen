import Flutter
import UIKit
#if canImport(FamilyControls)
import FamilyControls
#endif
#if canImport(DeviceActivity)
import DeviceActivity
#endif
#if canImport(ManagedSettings)
import ManagedSettings
#endif
#if canImport(StoreKit)
import StoreKit
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let lockEngineChannelName = "salah_guard/lock_engine"
  private let subscriptionChannelName = "one_deen/subscription_billing"
  private let lockEngineController = LockEngineController()
  private let subscriptionController = SubscriptionBillingController()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let lockChannel = FlutterMethodChannel(
        name: lockEngineChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      lockChannel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(false)
          return
        }
        self.handleLockEngineCall(call: call, result: result)
      }

      let subscriptionChannel = FlutterMethodChannel(
        name: subscriptionChannelName,
        binaryMessenger: controller.binaryMessenger
      )

      subscriptionChannel.setMethodCallHandler { [weak self] call, result in
        guard let self else {
          result(false)
          return
        }
        self.handleSubscriptionCall(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handleLockEngineCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestIosAuthorization":
      lockEngineController.requestIosAuthorization(result: result)
    case "syncConfiguration":
      guard let args = call.arguments as? [String: Any] else {
        result(FlutterError(code: "invalid_args", message: "Lock configuration payload is missing.", details: nil))
        return
      }
      result(lockEngineController.syncConfiguration(arguments: args))
    case "syncLockWindows":
      guard let args = call.arguments as? [String: Any] else {
        result(false)
        return
      }
      result(lockEngineController.syncLockWindows(arguments: args))
    case "syncBlockedApps":
      guard let args = call.arguments as? [String: Any] else {
        result(false)
        return
      }
      result(lockEngineController.syncBlockedApps(arguments: args))
    case "requestEmergencyUnlock":
      result(lockEngineController.requestEmergencyUnlock())
    case "scheduleAutomation":
      result(lockEngineController.scheduleAutomation())
    case "consumeResyncRequired":
      result(lockEngineController.consumeResyncRequired())
    case "isEngineHealthy":
      result(lockEngineController.isEngineHealthy())
    case "getEngineDiagnostics":
      result(lockEngineController.engineDiagnostics())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleSubscriptionCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSubscriptionCatalog":
      guard let args = call.arguments as? [String: Any] else {
        result(["available": false])
        return
      }
      subscriptionController.getCatalog(arguments: args, result: result)
    case "purchaseAnnualPlan":
      guard let args = call.arguments as? [String: Any] else {
        result(["status": "failed"])
        return
      }
      subscriptionController.purchase(arguments: args, result: result)
    case "restorePurchases":
      subscriptionController.restore(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

private struct LockConfiguration {
  let strictnessMode: String
  let lockBeforeMinutes: Int
  let lockAfterMinutes: Int
}

private struct LockWindowPayload {
  let prayerName: String
  let startEpochMillis: Int64
  let endEpochMillis: Int64
}

private final class LockEngineController {
  private enum Keys {
    static let appGroupIdentifier = "group.com.example.app.onedeen"
    static let strictnessMode = "lock_config.strictness_mode"
    static let lockBeforeMinutes = "lock_config.lock_before_minutes"
    static let lockAfterMinutes = "lock_config.lock_after_minutes"
    static let lockWindows = "lock_config.windows"
    static let blockedApps = "lock_config.blocked_apps"
    static let resyncRequired = "lock_config.resync_required"
    static let lastScheduleAt = "lock_config.last_schedule_at"
    static let scheduledActivityNames = "lock_config.scheduled_activity_names"
  }

  private let defaults: UserDefaults

  init(defaults: UserDefaults? = nil) {
    if let defaults {
      self.defaults = defaults
      return
    }

    self.defaults = UserDefaults(suiteName: Keys.appGroupIdentifier) ?? .standard
  }

  func requestIosAuthorization(result: @escaping FlutterResult) {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      Task {
        do {
          try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
          result(true)
        } catch {
          result(false)
        }
      }
      return
    }
    #endif
    result(false)
  }

  func syncConfiguration(arguments: [String: Any]) -> Bool {
    guard
      let strictnessMode = arguments["strictnessMode"] as? String,
      let lockBeforeMinutes = arguments["lockBeforeMinutes"] as? Int,
      let lockAfterMinutes = arguments["lockAfterMinutes"] as? Int
    else {
      return false
    }

    let configuration = LockConfiguration(
      strictnessMode: strictnessMode,
      lockBeforeMinutes: lockBeforeMinutes,
      lockAfterMinutes: lockAfterMinutes
    )

    defaults.set(configuration.strictnessMode, forKey: Keys.strictnessMode)
    defaults.set(configuration.lockBeforeMinutes, forKey: Keys.lockBeforeMinutes)
    defaults.set(configuration.lockAfterMinutes, forKey: Keys.lockAfterMinutes)
    return true
  }

  func syncLockWindows(arguments: [String: Any]) -> Bool {
    guard let windowsRaw = arguments["windows"] as? [[String: Any]] else {
      return false
    }

    defaults.set(windowsRaw, forKey: Keys.lockWindows)
    defaults.set(true, forKey: Keys.resyncRequired)

    #if canImport(DeviceActivity) && canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      return scheduleDeviceActivity(windowsRaw: windowsRaw)
    }
    #endif

    return false
  }

  func syncBlockedApps(arguments: [String: Any]) -> Bool {
    guard let packageNames = arguments["packageNames"] as? [String] else {
      return false
    }
    defaults.set(packageNames, forKey: Keys.blockedApps)
    return true
  }

  func requestEmergencyUnlock() -> Bool {
    true
  }

  func scheduleAutomation() -> Bool {
    defaults.set(true, forKey: Keys.resyncRequired)

    #if canImport(DeviceActivity) && canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      let windowsRaw = defaults.array(forKey: Keys.lockWindows) as? [[String: Any]] ?? []
      guard !windowsRaw.isEmpty else {
        return false
      }
      return scheduleDeviceActivity(windowsRaw: windowsRaw)
    }
    #endif

    return false
  }

  func consumeResyncRequired() -> Bool {
    let value = defaults.bool(forKey: Keys.resyncRequired)
    if value {
      defaults.set(false, forKey: Keys.resyncRequired)
    }
    return value
  }

  func isEngineHealthy() -> Bool {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      let approved = AuthorizationCenter.shared.authorizationStatus == .approved
      let lastScheduleAt = defaults.object(forKey: Keys.lastScheduleAt) as? Date
      let hasRecentSchedule = lastScheduleAt?.timeIntervalSinceNow ?? -999999 > -172800
      return approved && hasRecentSchedule
    }
    #endif
    return false
  }

  func engineDiagnostics() -> [String: Any] {
    #if canImport(FamilyControls)
    if #available(iOS 16.0, *) {
      let lastScheduleAt = defaults.object(forKey: Keys.lastScheduleAt) as? Date
      return [
        "authorizationStatus": "\(AuthorizationCenter.shared.authorizationStatus)",
        "lastScheduleAt": lastScheduleAt?.timeIntervalSince1970 ?? 0,
        "scheduledCount": (defaults.stringArray(forKey: Keys.scheduledActivityNames) ?? []).count,
      ]
    }
    #endif
    return [:]
  }

  #if canImport(DeviceActivity) && canImport(FamilyControls)
  @available(iOS 16.0, *)
  private func scheduleDeviceActivity(windowsRaw: [[String: Any]]) -> Bool {
    if AuthorizationCenter.shared.authorizationStatus != .approved {
      return false
    }

    let center = DeviceActivityCenter()
    let calendar = Calendar.current

    let previousNames = defaults.stringArray(forKey: Keys.scheduledActivityNames) ?? []
    previousNames.forEach { raw in
      center.stopMonitoring(DeviceActivityName(raw))
    }

    var newNames: [String] = []
    let now = Date()

    for (index, item) in windowsRaw.enumerated() {
      guard
        let startEpoch = (item["startEpochMillis"] as? NSNumber)?.int64Value,
        let endEpoch = (item["endEpochMillis"] as? NSNumber)?.int64Value
      else {
        continue
      }

      var startDate = Date(timeIntervalSince1970: TimeInterval(startEpoch) / 1000)
      let endDate = Date(timeIntervalSince1970: TimeInterval(endEpoch) / 1000)

      if endDate <= now {
        continue
      }

      if startDate <= now {
        startDate = now.addingTimeInterval(5)
      }

      let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
      let endComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endDate)

      if startComponents == endComponents {
        continue
      }

      let activityRawName = "onedeen.lock.\(index).\(startEpoch)"
      let activityName = DeviceActivityName(activityRawName)
      let schedule = DeviceActivitySchedule(
        intervalStart: startComponents,
        intervalEnd: endComponents,
        repeats: false
      )

      do {
        try center.startMonitoring(activityName, during: schedule)
        newNames.append(activityRawName)
      } catch {
        continue
      }
    }

    defaults.set(newNames, forKey: Keys.scheduledActivityNames)
    defaults.set(Date(), forKey: Keys.lastScheduleAt)
    defaults.set(false, forKey: Keys.resyncRequired)
    return !newNames.isEmpty
  }
  #endif
}

private final class SubscriptionBillingController {
  func getCatalog(arguments: [String: Any], result: @escaping FlutterResult) {
    guard let productId = arguments["productId"] as? String, !productId.isEmpty else {
      result(["available": false])
      return
    }

    #if canImport(StoreKit)
    if #available(iOS 15.0, *) {
      Task {
        do {
          let products = try await Product.products(for: [productId])
          guard let product = products.first else {
            result(["available": false])
            return
          }
          result([
            "available": true,
            "title": product.displayName,
            "description": product.description,
            "price": product.displayPrice,
            "currencyCode": ""
          ])
        } catch {
          result(["available": false])
        }
      }
      return
    }
    #endif
    result(["available": false])
  }

  func purchase(arguments: [String: Any], result: @escaping FlutterResult) {
    guard let productId = arguments["productId"] as? String, !productId.isEmpty else {
      result(["status": "failed"])
      return
    }

    #if canImport(StoreKit)
    if #available(iOS 15.0, *) {
      Task {
        do {
          let products = try await Product.products(for: [productId])
          guard let product = products.first else {
            result(["status": "failed", "reason": "product_not_found"])
            return
          }

          let purchaseResult = try await product.purchase()
          switch purchaseResult {
          case .success(let verification):
            switch verification {
            case .verified(let transaction):
              let receiptData = String(transaction.id)
              await transaction.finish()
              result([
                "status": "purchased",
                "provider": "ios",
                "productId": productId,
                "receiptToken": receiptData,
                "orderId": String(transaction.originalID)
              ])
            case .unverified:
              result(["status": "failed", "reason": "unverified_transaction"])
            }
          case .pending:
            result(["status": "pending"])
          case .userCancelled:
            result(["status": "cancelled"])
          @unknown default:
            result(["status": "failed"])
          }
        } catch {
          result(["status": "failed"])
        }
      }
      return
    }
    #endif
    result(["status": "failed", "reason": "storekit_unavailable"])
  }

  func restore(result: @escaping FlutterResult) {
    #if canImport(StoreKit)
    if #available(iOS 15.0, *) {
      Task {
        var restored: [[String: String]] = []
        for await entitlement in Transaction.currentEntitlements {
          if case .verified(let transaction) = entitlement {
            let productId = transaction.productID
            restored.append([
              "provider": "ios",
              "productId": productId,
              "receiptToken": String(transaction.id),
              "orderId": String(transaction.originalID)
            ])
          }
        }
        result(restored)
      }
      return
    }
    #endif
    result([])
  }
}
