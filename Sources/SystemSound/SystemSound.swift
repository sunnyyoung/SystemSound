//
//  SystemSound.swift
//  SystemSound
//
//  Created by Sunny Young on 2024/7/16.
//

import AVFoundation

// MARK: - SystemSound

/// A class to manage system audio settings and notifications.
open class SystemSound {
    /// The global instance of SystemSound.
    public static let global = SystemSound()

    // MARK: - Private Structures

    private struct Address {
        /// The property address for the default output device.
        static let device = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        /// The property address for the mute state.
        static let muted = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyMute,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        /// The property address for the volume.
        static let volume = AudioObjectPropertyAddress(
            mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )
    }

    private struct Listener {
        /// Listener for device changes.
        static let device: AudioObjectPropertyListenerBlock = { _, _ in
            SystemSound.global.reload()
        }

        /// Listener for mute state changes.
        static let muted: AudioObjectPropertyListenerBlock = { _, _ in
            NotificationCenter.default.post(name: .SoundServiceMutedDidChange, object: nil)
        }

        /// Listener for volume changes.
        static let volume: AudioObjectPropertyListenerBlock = { _, _ in
            NotificationCenter.default.post(name: .SoundServiceVolumeDidChange, object: nil)
        }
    }

    // MARK: - Private Properties

    /// The ID of the default audio device.
    private var defaultDevice: AudioDeviceID? {
        didSet {
            guard defaultDevice != oldValue else {
                return
            }

            var address = (
                muted: Address.muted,
                volume: Address.volume
            )

            if let device = oldValue {
                AudioObjectRemovePropertyListenerBlock(device, &address.muted, .main, Listener.muted)
                AudioObjectRemovePropertyListenerBlock(device, &address.volume, .main, Listener.volume)
            }

            if let device = defaultDevice {
                AudioObjectAddPropertyListenerBlock(device, &address.muted, .main, Listener.muted)
                AudioObjectAddPropertyListenerBlock(device, &address.volume, .main, Listener.volume)
            }

            NotificationCenter.default.post(name: .SoundServiceDefaultDeviceDidChange, object: nil)
        }
    }

    // MARK: - Public Properties

    /// The current mute state and volume of the default audio device.
    open var value: (muted: Bool, volume: Float) {
        get {
            guard let device = defaultDevice else {
                return (false, .zero)
            }

            var address = (
                muted: Address.muted,
                volume: Address.volume
            )

            var size = (
                muted: UInt32(MemoryLayout<UInt32>.size),
                volume: UInt32(MemoryLayout<Float>.size)
            )

            var value = (
                muted: false,
                volume: Float.zero
            )

            if AudioObjectHasProperty(device, &address.muted) {
                AudioObjectGetPropertyData(device, &address.muted, 0, nil, &size.muted, &value.muted)
            }

            if AudioObjectHasProperty(device, &address.volume) {
                AudioObjectGetPropertyData(device, &address.volume, 0, nil, &size.volume, &value.volume)
            }

            return value
        }

        set {
            guard let device = defaultDevice else {
                return
            }

            var address = (
                muted: Address.muted,
                volume: Address.volume
            )

            let size = (
                muted: UInt32(MemoryLayout<UInt32>.size),
                volume: UInt32(MemoryLayout<Float>.size)
            )

            var value = (
                muted: UInt32(newValue.muted ? 1 : 0),
                volume: max(min(newValue.volume, 100.0), 0.0)
            )

            if AudioObjectHasProperty(device, &address.muted) {
                AudioObjectSetPropertyData(device, &address.muted, 0, nil, size.muted, &value.muted)
            }

            if AudioObjectHasProperty(device, &address.volume) {
                AudioObjectSetPropertyData(device, &address.volume, 0, nil, size.volume, &value.volume)
            }
        }
    }

    // MARK: - Initialization

    /// Initializes the SystemSound instance and sets up the device change listener.
    public init() {
        var address = Address.device
        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            .main,
            Listener.device
        )
    }

    /// Removes the device change listener when the instance is deinitialized.
    deinit {
        var address = Address.device
        AudioObjectRemovePropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            .main,
            Listener.device
        )
    }

    // MARK: - Public Methods

    /// Loads the current audio device settings.
    open func load() {
        self.reload()
    }

    /// Increases the system volume by the specified amount.
    /// - Parameter volume: The amount to increase the volume by (default is 0.1).
    open func increaseVolume(_ volume: Float = 0.1) {
        let value = SystemSound.global.value
        SystemSound.global.value = (value.muted, value.volume + volume)
    }

    /// Decreases the system volume by the specified amount.
    /// - Parameter volume: The amount to decrease the volume by (default is 0.1).
    open func decreaseVolume(_ volume: Float = 0.1) {
        let value = SystemSound.global.value
        SystemSound.global.value = (value.muted, value.volume - volume)
    }

    // MARK: - Private Methods

    /// Reloads the default audio device.
    private func reload() {
        self.defaultDevice = {
            var address = Address.device

            var id = kAudioObjectUnknown
            var size = UInt32(MemoryLayout.size(ofValue: id))

            guard
                AudioObjectHasProperty(AudioObjectID(kAudioObjectSystemObject), &address),
                AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id) == OSStatus(noErr),
                id != kAudioObjectUnknown
            else {
                return nil
            }

            return id
        }()
    }
}

// MARK: - Notification Name Extensions

extension Notification.Name {
    /// Notification posted when the default audio device changes.
    public static var SoundServiceDefaultDeviceDidChange: Notification.Name {
        .init("SoundService.DefaultDeviceDidChange")
    }

    /// Notification posted when the muted state of the audio device changes.
    public static var SoundServiceMutedDidChange: Notification.Name {
        .init("SoundService.MutedDidChangeNotification")
    }

    /// Notification posted when the volume of the audio device changes.
    public static var SoundServiceVolumeDidChange: Notification.Name {
        .init("SoundService.VolumeDidChangeNotification")
    }
}
