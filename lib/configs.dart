// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

const APP_NAME = 'uniCare HHC';
const APP_LOGO_URL = '$DOMAIN_URL/img/logo/mini_logo.png';
const DEFAULT_LANGUAGE = 'en';

///Live Url
// const DOMAIN_URL = "http://127.0.0.1:8000";
const DOMAIN_URL = "https://unicarehhc.com/unicare";

const BASE_URL = '$DOMAIN_URL/api/';

const APP_PLAY_STORE_URL = '';
const APP_APPSTORE_URL = '';

const TERMS_CONDITION_URL = '$DOMAIN_URL/page/terms-conditions';
const PRIVACY_POLICY_URL = '$DOMAIN_URL/page/privacy-policy';
const INQUIRY_SUPPORT_EMAIL = 'shamjaan78@gmail.com';

/// You can add help line number here for contact.
const HELP_LINE_NUMBER = '+923473699119';

//region Payment Gateway
//region STRIPE
const STRIPE_URL = 'https://api.stripe.com/v1/payment_intents';
const STRIPE_merchantIdentifier = "merchant.flutter.stripe.test";
const STRIPE_CURRENCY_CODE = 'AED';
//endregion

/// PAYSTACK
const String payStackCurrency = "AED";

/// PAYPAl
const String payPalSupportedCurrency = 'AED';

/// Airtel Money Payments
///It Supports ["UGX", "NGN", "TZS", "KES", "RWF", "ZMW", "CFA", "XOF", "XAF", "CDF", "USD", "XAF", "SCR", "MGA", "MWK"]
const airtel_currency_code = "MWK";
const airtel_country_code = "MW";
const AIRTEL_BASE = kDebugMode
    ? 'https://openapiuat.airtel.africa/'
    : "https://openapi.airtel.africa";

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

//end region
