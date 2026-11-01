import 'package:flutter/material.dart';
import 'package:unicare_patient/utils/app_common.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openWhatsAppSupport(BuildContext context) async {
  // const String phoneNumber = "971501364393"; // without +
  String phoneNumber =
      appConfigs.value.whatsappSupportNumber.toString(); // without +
  const String message =
      "I need assistance regarding the booking of service through Unicare Healthcare App. Please guide further.";

  final Uri whatsappUri = Uri.parse(
    "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
  );

  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("WhatsApp is not installed on this device."),
      ),
    );
  }
}
