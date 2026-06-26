import 'package:flutter/material.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

import '../components/extended_form_fields.dart';

Widget _frame(Widget child) => SizedBox(
      width: 380,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );

final extendedFormStories = <Story>[
  Story(
    name: 'Inputs/Search Field',
    description: 'Rounded search input with clear button.',
    builder: (_) => _frame(const TransfloSearchField(hint: 'Search loads, BOL #, customer…')),
  ),
  Story(
    name: 'Inputs/Numeric Stepper',
    description: 'Quantity stepper with +/- controls.',
    builder: (_) => _frame(const TransfloNumericStepper(
      label: 'Pallet count',
      value: 4,
      min: 0,
      max: 30,
    )),
  ),
  Story(
    name: 'Inputs/Currency Field',
    description: 'Auto-formatted dollars input.',
    builder: (_) => _frame(const TransfloCurrencyField(
      label: 'Detention rate',
    )),
  ),
  Story(
    name: 'Inputs/Phone Field',
    description: 'US phone number with auto-formatting.',
    builder: (_) => _frame(const TransfloPhoneField(label: 'Driver phone')),
  ),
  Story(
    name: 'Inputs/Multi-Select Chips',
    description: 'Toggleable chip set for picking multiple options.',
    builder: (_) => _frame(const TransfloChipMultiSelect(
      label: 'Accessorials',
      options: [
        'Lumper',
        'Detention',
        'Layover',
        'Tarp',
        'Hazmat',
        'Tonu',
        'Fuel surcharge',
      ],
      initial: ['Lumper', 'Tarp'],
    )),
  ),
  Story(
    name: 'Inputs/Segmented Control',
    description: '2–4 mutually exclusive inline options.',
    builder: (_) => _frame(const TransfloSegmented(
      label: 'Trailer type',
      options: ['Dry van', 'Reefer', 'Flatbed'],
    )),
  ),
  Story(
    name: 'Inputs/Photo Upload',
    description: 'Attach photos (POD, BOL, damage).',
    builder: (_) => _frame(const TransfloPhotoUpload(label: 'Attachments')),
  ),
  Story(
    name: 'Inputs/Signature Pad',
    description: 'Proof-of-delivery signature capture.',
    builder: (_) => _frame(const TransfloSignaturePad(label: 'Consignee signature')),
  ),
  Story(
    name: 'Inputs/OTP Input',
    description: '6-digit verification code; supports paste.',
    builder: (_) => _frame(const TransfloOtpInput(label: 'Verification code')),
  ),
  Story(
    name: 'Inputs/Address Autocomplete',
    description: 'Address field with suggestion dropdown.',
    builder: (_) => _frame(const TransfloAddressField(label: 'Pickup address')),
  ),
  Story(
    name: 'Inputs/Range Slider',
    description: 'Two-thumb range selector (e.g., weight, distance).',
    builder: (_) => _frame(const TransfloRangeSlider(
      label: 'Weight range',
      min: 0,
      max: 80000,
      initial: RangeValues(15000, 45000),
      unit: ' lbs',
    )),
  ),
  Story(
    name: 'Inputs/Notes',
    description: 'Multi-line notes with character counter.',
    builder: (_) => _frame(const TransfloNotesField(
      label: 'Driver notes',
      maxLength: 240,
    )),
  ),
];
