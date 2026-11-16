## 1.4.0

* Vendored the `alghwalbi_dropdown` package into `lib/core/widgets/custom_dropdown/` (byte-identical clone, re-exported from the library) and removed the external dependency. Consumers now depend solely on `omni_core`.
* Form Builder: the Dynamic Dropdown now renders with the new `DynamicCustomDropdown` component (same look, feel and animations as the static dropdown) instead of a dialog popup, with paged loading, debounced server-side search, error/retry state, and dependent dropdown support.

## 1.3.0

* Form Builder: new Dynamic Dropdown field (`FormFieldType.dynamicDropdown`). Options are fetched from the backend form-entities endpoint through a host-provided `DynamicDropdownOptionsFetcher`, with server-side search, infinite-scroll pagination, retry on failure, and dependent (parent/child) dropdown support.

## 0.0.1

* TODO: Describe initial release.
