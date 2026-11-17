part of '../../../omni_core.dart';

/// Top-level background message handler (must not be inside a class)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  PackageLogger.info(
    '🌙 Background message received: ${message.messageId}',
    tag: 'Push Notifications Service',
  );
}

class PushNotificationService {
  /// Callback invoked when this app instance is registered with Firebase Cloud
  /// Messaging, and again whenever its registration ID changes.
  /// Use this to send the ID to your backend so it can target this device.
  final Future<void> Function({
    /// The Firebase Installation ID (FID) that identifies this app instance
    /// as an FCM direct-send target.
    required String notificationDeviceToken,
  })
  registerDeviceTokenToServerMethod;

  /// Callback invoked when a device token is unregistered.
  final Future<bool> Function() unregisterDeviceTokenToServerMethod;

  /// Callback invoked every time a notification is receivedv while the app is in foreground, background, or when the user taps a notification to open the app.
  /// * ['message'] — the full `RemoteMessage` object
  final Future<void> Function({
    /// The `RemoteMessage` payload of the notification.
    required RemoteMessage? message,
  })
  onReceiveNotification;
  PushNotificationService({
    required this.registerDeviceTokenToServerMethod,
    required this.unregisterDeviceTokenToServerMethod,
    required this.onReceiveNotification,
  });

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _registrationSubscription;
  String? _lastRegisteredId;

  /// Initialize Firebase Messaging
  Future<void> init() async {
    try {
      // 1️⃣ Request permission first (required for iOS/macOS and Android 13+)
      final bool permissionGranted = await _requestNotificationPermission();

      if (!permissionGranted) {
        PackageLogger.warning(
          '❌ Notification permission denied, push notifications will not work',
          tag: 'Push Notifications Service',
        );
        return;
      }
      // 2️⃣ Configure how foreground notifications appear
      await _setupForegroundNotification();
      // 3️⃣ Register with FCM and keep the backend in sync with the FID
      await _registerDevice();
      // 4️⃣ Start listeners for messages
      _setupListeners();
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Notification initialization failed',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
    }
  }

  /// Ask user for notification permissions (iOS/macOS and Android)
  Future<bool> _requestNotificationPermission() async {
    try {
      // For iOS/macOS - use Firebase's permission request
      if (Platform.isIOS || Platform.isMacOS) {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional:
              false, // Set to true for provisional permissions (quiet delivery)
        );

        PackageLogger.info(
          '🔑 iOS Notification permission: ${settings.authorizationStatus}',
          tag: 'Push Notifications Service',
        );

        return settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      }
      // For Android - use permission_handler for all versions
      else if (Platform.isAndroid) {
        return await _requestAndroidNotificationPermission();
      }
      // For other platforms (web, etc.)
      else {
        PackageLogger.info(
          '🔑 Notification permissions handled by platform defaults',
          tag: 'Push Notifications Service',
        );
        return true;
      }
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Notification permission request failed',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
      return false;
    }
  }

  /// Handle Android notification permissions for all versions
  Future<bool> _requestAndroidNotificationPermission() async {
    try {
      // Use permission_handler for all Android versions
      final status = await Permission.notification.request();

      PackageLogger.info(
        '🔑 Android Notification permission: $status',
        tag: 'Push Notifications Service',
      );

      return status.isGranted || status.isLimited;
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Android notification permission request failed',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
      // If permission handler fails, fall back to default behavior
      return true;
    }
  }

  /// Configure how notifications show while app is in foreground
  Future<void> _setupForegroundNotification() async {
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Register this app instance with FCM. The FID arrives on [FirebaseMessaging.onRegistered],
  /// which also fires when the FID changes, so the backend stays in sync.
  Future<void> _registerDevice() async {
    try {
      // onRegistered is a broadcast stream without replay, so listen before
      // calling register() or the first FID can be missed.
      await _registrationSubscription?.cancel();
      _registrationSubscription = _firebaseMessaging.onRegistered.listen(
        _onDeviceRegistered,
        onError: (Object err, StackTrace trace) => PackageLogger.error(
          '🔥 FCM registration stream error',
          error: err,
          stackTrace: trace,
          tag: 'Push Notifications Service',
        ),
      );
      await _firebaseMessaging.register();
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Device token registration failed',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
    }
  }

  Future<void> _onDeviceRegistered(String installationId) async {
    if (installationId.isEmpty || installationId == _lastRegisteredId) return;
    _lastRegisteredId = installationId;
    await _sendNotificationTokenToServer(
      notificationDeviceToken: installationId,
    );
  }

  /// Register Notification Token
  Future<void> _sendNotificationTokenToServer({
    required String notificationDeviceToken,
  }) async {
    try {
      await registerDeviceTokenToServerMethod(
        notificationDeviceToken: notificationDeviceToken,
      );
    } catch (e, stackTrace) {
      PackageLogger.error(
        '📛 Token registration error',
        error: e,
        stackTrace: stackTrace,
        tag: 'Push Notifications Service',
      );
    }
  }

  /// Unregister Notification Token
  Future<bool> unRegisterNotificaitonDeviceToken() async {
    try {
      /// 1: call unRegisterDeviceToken method
      final result = await unregisterDeviceTokenToServerMethod();
      if (result) {
        /// 2: stop syncing FID changes, then unregister from FCM
        await _registrationSubscription?.cancel();
        _registrationSubscription = null;
        _lastRegisteredId = null;
        await _firebaseMessaging.unregister();
        return true;
      }
      return false;
    } catch (ex, st) {
      PackageLogger.error(
        '🔥 Token unregistration error',
        error: ex,
        stackTrace: st,
        tag: 'Push Notifications Service',
      );
      return false;
    }
  }

  /// Setup message listeners
  void _setupListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // When user taps a notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppMessage);

    /// Background messages [top-level function]
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      PackageLogger.info(
        '📩 Foreground message received: ${message.data}',
        tag: 'Push Notifications Service',
      );
      if (message.notification != null) {
        await _processNotificationWhenReceived(message: message);
      }
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Foreground message handling error',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
    }
  }

  /// Handle opened app messages
  Future<void> _handleOpenedAppMessage(RemoteMessage message) async {
    try {
      PackageLogger.info(
        '📲 Notification opened: ${message.data}',
        tag: 'Push Notifications Service',
      );
      await _processNotificationWhenReceived(message: message);
    } catch (err, trace) {
      PackageLogger.error(
        '🔥 Opened message handling error',
        error: err,
        stackTrace: trace,
        tag: 'Push Notifications Service',
      );
    }
  }

  /// Process notification and navigate if necessary
  Future<void> _processNotificationWhenReceived({
    RemoteMessage? message,
  }) async {
    try {
      /// 1: Show Notification
      toastification.dismissAll();
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.minimal,
        overlayState: AppRouter.navigatorKey.currentState?.overlay,
        autoCloseDuration: const Duration(seconds: 3),
        animationDuration: const Duration(milliseconds: 700),
        showProgressBar: true,
        backgroundColor: Colors.white,
        showIcon: true,
        icon: const Icon(Icons.notifications_active_outlined),
        alignment: Alignment.topCenter,
        pauseOnHover: true,
        dragToClose: true,
        callbacks: ToastificationCallbacks(
          onTap: (toastItem) =>
              PackageLogger.info('Toast ${toastItem.id} tapped'),
          onCloseButtonTap: (toastItem) =>
              PackageLogger.info('Toast ${toastItem.id} close button tapped'),
          onAutoCompleteCompleted: (toastItem) =>
              PackageLogger.info('Toast ${toastItem.id} completed'),
          onDismissed: (toastItem) =>
              PackageLogger.info('Toast ${toastItem.id} dismissed'),
        ),
        title: Text(
          message?.notification?.title ?? 'New Notification',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        description: (message?.notification?.body?.isNotEmpty ?? false)
            ? Text(
                message?.notification?.body ?? '',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              )
            : null,
      );

      /// 2: if there additional proccess on received notification
      await onReceiveNotification(message: message);
    } catch (ex, st) {
      PackageLogger.error(
        '🔥 Notification processing error',
        error: ex,
        stackTrace: st,
        tag: 'Push Notifications Service',
      );
    }
  }

  /// Method to check current permission status
  Future<bool> getNotificationPermissionStatus() async {
    if (Platform.isIOS || Platform.isMacOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } else if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted || status.isLimited;
    } else {
      return true;
    }
  }
}
