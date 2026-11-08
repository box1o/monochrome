import QtQml
import Quickshell
import "shell"
import "services"
import "theme"
import "features/calendar/models"
import "features/notch"
import "features/notch/models"

ShellRoot {
    MonoTokens {
        id: themeTokens
    }

    NotchStyle {
        id: notchStyle
    }

    ClockService {
        id: systemClock
    }

    MonthActivity {
        id: monthActivity

        today: systemClock.today
    }

    ApplicationsService {
        id: applicationCatalog
    }

    MediaService {
        id: mediaSource
    }

    VpnService {
        id: vpnSource
    }

    BrightnessService {
        id: displayBrightness
    }

    AudioProfiles {
        id: audioProfiles
    }

    AudioService {
        id: audioSource
    }

    WifiService {
        id: wifiSource
    }

    BluetoothService {
        id: bluetoothSource
    }

    CoffeeService {
        id: coffeeSource
    }

    PhoneService {
        id: phoneSource
    }

    SessionService {
        id: sessionSource
    }

    NotificationsService {
        id: notificationsSource
    }

    RecordingService {
        id: recordingSource
    }

    PomodoroService {
        id: pomodoroSource
    }

    PowerService {
        id: powerSource
    }

    FeedbackSounds {
        id: feedbackSounds
    }

    NotchFeedback {
        id: notchFeedback

        brightness: displayBrightness
        audio: audioSource
        power: powerSource
        bluetooth: bluetoothSource
        onSoundRequested: (name) => {
            return feedbackSounds.play(name);
        }
    }

    ScreenPolicy {
        id: screens

        screens: Quickshell.screens
    }

    Variants {
        model: screens.selected ? [screens.selected] : []

        Notch {
            required property var modelData

            screen: modelData
            coffee: coffeeSource
            phone: phoneSource
            session: sessionSource
            notifications: notificationsSource
            power: powerSource
            recording: recordingSource
            pomodoro: pomodoroSource
            profiles: audioProfiles
            media: mediaSource
            vpn: vpnSource
            brightness: displayBrightness
            audio: audioSource
            wifi: wifiSource
            bluetooth: bluetoothSource
            applications: applicationCatalog
            tokens: themeTokens
            style: notchStyle
            month: monthActivity
            feedback: notchFeedback
            clock: systemClock
            onExpandedChanged: systemClock.detailed = expanded
            Component.onDestruction: {
                if (systemClock)
                    systemClock.detailed = false;
            }
        }
    }
}
