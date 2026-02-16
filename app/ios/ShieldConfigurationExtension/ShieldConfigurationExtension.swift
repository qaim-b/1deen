import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    return ShieldConfiguration(
      backgroundBlurStyle: .systemUltraThinMaterialDark,
      backgroundColor: UIColor.black.withAlphaComponent(0.84),
      icon: UIImage(systemName: "moon.stars.fill"),
      title: ShieldConfiguration.Label(
        text: "1Deen",
        color: UIColor.white
      ),
      subtitle: ShieldConfiguration.Label(
        text: "Salah window is active. Take a short pause for prayer.",
        color: UIColor(white: 0.86, alpha: 1)
      ),
      primaryButtonLabel: ShieldConfiguration.Label(
        text: "I Have Prayed",
        color: UIColor.white
      ),
      primaryButtonBackgroundColor: UIColor.systemGreen,
      secondaryButtonLabel: ShieldConfiguration.Label(
        text: "Emergency 30s",
        color: UIColor.white
      )
    )
  }
}
