import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:unicare_patient/main.dart';

import '../../service/model/service_list_model.dart';

class DoctorServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;

  const DoctorServiceCard({super.key, required this.serviceElement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceElement.serviceName,
            overflow: TextOverflow.ellipsis,
            style: boldTextStyle(size: 16),
          ),
          16.height,
          Row(
            children: [
              Text(
                "${locale.value.totalAppointments}:",
                style: secondaryTextStyle(size: 14),
              ),
              4.width,
              Text(
                "${serviceElement.totalAppointments}",
                style: primaryTextStyle(),
              ),
            ],
          ),
          8.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${locale.value.clinicName}:",
                style: secondaryTextStyle(size: 14),
              ).flexible(),
              4.width,
              Text(
                serviceElement.clinicName.map((e) => e.validate()).toList().join(', '),
                style: primaryTextStyle(),
              ).flexible(),
            ],
          ),
        ],
      ),
    );
  }
}
