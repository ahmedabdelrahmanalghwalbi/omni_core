library;

/// Imports
import 'package:material_ui/material_ui.dart';
// toastification still exposes legacy Material types in its public API.
// Remove once it migrates to material_ui.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter/foundation.dart';

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as widgets_import;
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_package;
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

import 'dart:developer' as developer;

import 'package:syncfusion_flutter_charts/charts.dart' as syncfusion_charts;
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';

import 'core/widgets/custom_dropdown/custom_dropdown.dart';
export 'core/widgets/custom_dropdown/custom_dropdown.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';

import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:app_settings/app_settings.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:android_id/android_id.dart';
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion_pdf;

/// Router
part 'router/app.router.dart';

/// Constants
part 'core/constants/package_assets.constants.dart';

/// Utils
part 'core/utils/package_logger.utils.dart';
part 'core/utils/datetime.utils.dart';
part 'core/utils/address.utils.dart';
part 'core/utils/toast.utils.dart';
part 'core/utils/location_permission_handler.utils.dart';
part 'core/utils/location.utils.dart';
part 'core/utils/formate_phone_number.utils.dart';
part 'core/utils/camera.utils.dart';
part 'core/utils/info.utils.dart';
part 'core/utils/flavor.utils.dart';
part 'core/utils/layout.utils.dart';
part 'core/utils/colors.utils.dart';
part 'core/utils/modal_sheet.utils.dart';
part 'core/utils/string.utils.dart';
part 'core/utils/app_image_cache_manager.utils.dart';
part 'core/utils/notification_badge.utils.dart';

/// Models
part 'core/models/app_base.model.dart';
part 'core/models/operation_result.model.dart';

/// Services
part 'core/services/api/api_logging/api.logger.dart';
part 'core/services/api/api_service_helpers.interface.dart';
part 'core/services/api/api_service.interface.dart';
part 'core/services/api/dio_api_service/dio_api_cancel_token_manager.service.dart';
part 'core/services/api/dio_api_service/dio_api.service.dart';
part 'core/services/internet_connection/internet_connection.service.dart';
part 'core/services/push_notifications/push_notifications.service.dart';

/// Form Builder Models
part 'core/form_builder/models/form_field.model.dart';
part 'core/form_builder/models/form_schema_capabilities.model.dart';
part 'core/form_builder/models/visibility_rules.model.dart';
part 'core/form_builder/models/enums/form_field_types.enum.dart';
part 'core/form_builder/models/enums/calculation_operator.enum.dart';
part 'core/form_builder/models/inputs_form_fields/checkbox_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/number_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/signature_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/text_area_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/text_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/take_photo_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/multiple_take_photos_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/file_uploader_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/datetime_picker_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/date_picker_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/dropdown_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/dynamic_dropdown_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/dynamic_dropdown_options.model.dart';
part 'core/form_builder/models/inputs_form_fields/multi_select_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/dynamic_multi_select_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/radio_group_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/toggle_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/image_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/link_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/label_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/header_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/progress_line_form_field.model.dart';
part 'core/form_builder/models/statics_form_fields/progress_circle_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/derived_value_form_field.model.dart';
part 'core/form_builder/models/inputs_form_fields/computed_value_form_field.model.dart';
part 'core/form_builder/models/structure_form_fields/container_form_field.model.dart';
part 'core/form_builder/models/structure_form_fields/repeating_group_form_field.model.dart';
part 'core/form_builder/models/input_form_field.model.dart';
part 'core/form_builder/models/static_form_field.model.dart';
part 'core/form_builder/models/structure_form_field.model.dart';

/// Form Builder Views
part 'core/form_builder/engine/form_field_scope.utils.dart';
part 'core/form_builder/engine/form_visibility.utils.dart';
part 'core/form_builder/engine/form_calculation.utils.dart';
part 'core/form_builder/views/form_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/checkbox_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/number_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/signature_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/text_area_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/text_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/take_photo_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/multiple_take_photos_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/file_uploader_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/datetime_picker_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/date_picker_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/dropdown_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/dynamic_dropdown_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/multi_select_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/dynamic_multi_select_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/selected_values_read_only_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/radio_group_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/toggle_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/image_form_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/link_form_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/label_form_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/header_form_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/progress_line_field.widget.dart';
part 'core/form_builder/views/statics_form_fields/progress_circle_field.widget.dart';
part 'core/form_builder/views/inputs_form_fields/calculated_value_field.widget.dart';
part 'core/form_builder/views/structure_form_fields/container_field.widget.dart';
part 'core/form_builder/views/structure_form_fields/repeating_group_field.widget.dart';
part 'core/form_builder/views/structure_form_fields/repeating_group_item_action.widget.dart';
part 'core/form_builder/views/field_title_with_required.widget.dart';
part 'core/form_builder/views/field_validation_message.widget.dart';

/// PDF Annotation
part 'core/pdf_annotation/models/pdf_annotation.model.dart';
part 'core/pdf_annotation/models/pdf_annotation_texts.model.dart';
part 'core/pdf_annotation/utils/pdf_annotation_text_layout.utils.dart';
part 'core/pdf_annotation/utils/pdf_annotation.controller.dart';
part 'core/pdf_annotation/utils/pdf_annotation_export.utils.dart';
part 'core/pdf_annotation/views/pdf_annotation_editor.view.dart';
part 'core/pdf_annotation/views/pdf_annotation_page.widget.dart';
part 'core/pdf_annotation/views/pdf_annotation_toolbar.widget.dart';
part 'core/pdf_annotation/views/pdf_annotation_text_dialog.widget.dart';

/// commom/widgets
part 'core/widgets/custom_action_button.widget.dart';
part 'core/widgets/custom_divider.widget.dart';
part 'core/widgets/custom_elevated_button.widget.dart';
part 'core/widgets/custom_textfield_with_label.widget.dart';
part 'core/widgets/placeholder.widget.dart';
part 'core/widgets/general_appbar.widget.dart';
part 'core/widgets/language_switcher_button.widget.dart';
part 'core/widgets/multi_select_option.widget.dart';
part 'core/widgets/search_box.widget.dart';
part 'core/widgets/select_option.widget.dart';
part 'core/widgets/custom_animated_her_popup/custom_animated_hero_popup.widget.dart';
part 'core/widgets/custom_animated_her_popup/animations/hero_dialog_route.dart';
part 'core/widgets/custom_animated_her_popup/animations/custom_rect_tween.dart';
part 'core/widgets/orientation_initializer.widget.dart';
part 'core/widgets/gradient_floating_action_button.widget.dart';
