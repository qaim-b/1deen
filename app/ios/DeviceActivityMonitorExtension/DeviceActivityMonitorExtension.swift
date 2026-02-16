import DeviceActivity
import FamilyControls
import ManagedSettings

@available(iOS 16.0, *)
final class DeviceActivityMonitorExtension: DeviceActivityMonitor {
  private enum Keys {
    static let appGroupIdentifier = "group.com.example.app.onedeen"
    static let familySelectionData = "screen_time.family_selection"
  }

  private let store = ManagedSettingsStore()
  private let defaults = UserDefaults(suiteName: Keys.appGroupIdentifier)

  override func intervalDidStart(for activity: DeviceActivityName) {
    super.intervalDidStart(for: activity)
    applyShield()
  }

  override func intervalDidEnd(for activity: DeviceActivityName) {
    super.intervalDidEnd(for: activity)
    store.clearAllSettings()
  }

  private func applyShield() {
    guard let selection = loadSelection() else {
      store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
      return
    }

    let hasSelection = !selection.applicationTokens.isEmpty
      || !selection.categoryTokens.isEmpty
      || !selection.webDomainTokens.isEmpty

    guard hasSelection else {
      store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
      return
    }

    store.shield.applications = selection.applicationTokens
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(
      selection.categoryTokens,
      except: Set()
    )
    store.shield.webDomains = selection.webDomainTokens
  }

  private func loadSelection() -> FamilyActivitySelection? {
    guard let data = defaults?.data(forKey: Keys.familySelectionData) else {
      return nil
    }

    do {
      return try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
    } catch {
      return nil
    }
  }
}
