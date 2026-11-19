## 2.0.2

* `PushNotificationService` is back on the FCM registration token flow (`getToken`/`onTokenRefresh`/`deleteToken`). `registerDeviceTokenToServerMethod` receives the FCM registration token again, as in 1.x, and is called again whenever the token refreshes. This fixes `API disabled` errors on Android for apps that have not opted in to Firebase Installation ID registration, and no backend change is needed.

## 2.0.1

* Completed the MIT `LICENSE` text so pub.dev detects the license.
* Added the `repository` field and a clearer package description to `pubspec.yaml`.

## 2.0.0

* **Breaking:** migrated from the deprecated SDK libraries `package:flutter/material.dart` and `package:flutter/cupertino.dart` to `package:material_ui` and `package:cupertino_ui`. Public APIs now take `material_ui` types (for example `ButtonStyle` and `InputDecoration`), and widgets resolve `Material`, `Theme` and `MaterialLocalizations` from the `material_ui` tree. This fixes `No Material widget found` and lost theming when omni_core widgets are used in apps built with `material_ui`.
* **Breaking:** removed `HttpApiService` and the `http`, `http_parser` and `mime` dependencies. Use `DioApiService`.
* Requires Flutter `>=3.47.0` and Dart `^3.13.0`, the minimum required by `material_ui`, `cupertino_ui` and the current plugin releases.
* Upgraded all dependencies to their latest releases, including `firebase_core` 5, `firebase_messaging` 17, Syncfusion 35, `app_settings` 9, `android_id` 1 and `shimmer` 4. Consuming apps need Android `minSdk` 24 and iOS 15.0.
* **Breaking (backend):** `PushNotificationService` now uses the `firebase_messaging` 17 registration APIs (`register`/`onRegistered`/`unregister`) instead of the deprecated `getToken`/`deleteToken`. `registerDeviceTokenToServerMethod` now receives the Firebase Installation ID (FID), not an FCM registration token, and is called again whenever the FID changes. The backend must send pushes to the FID through FCM direct send. Unregistering stops FID syncing until `init()` runs again.
* Removed the deprecated lint rules `avoid_null_checks_in_equality_operators` and `unnecessary_await_in_return`.

## 1.4.0

* Vendored the `alghwalbi_dropdown` package into `lib/core/widgets/custom_dropdown/` (byte-identical clone, re-exported from the library) and removed the external dependency. Consumers now depend solely on `omni_core`.
* Form Builder: the Dynamic Dropdown now renders with the new `DynamicCustomDropdown` component (same look, feel and animations as the static dropdown) instead of a dialog popup, with paged loading, debounced server-side search, error/retry state, and dependent dropdown support.

## 1.3.0

* Form Builder: new Dynamic Dropdown field (`FormFieldType.dynamicDropdown`). Options are fetched from the backend form-entities endpoint through a host-provided `DynamicDropdownOptionsFetcher`, with server-side search, infinite-scroll pagination, retry on failure, and dependent (parent/child) dropdown support.
