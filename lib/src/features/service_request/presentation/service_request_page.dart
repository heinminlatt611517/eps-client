import 'package:flutter/material.dart';

import '../../../common_widgets/custom_app_bar_view.dart';

class ServiceRequestPage extends StatelessWidget {
  const ServiceRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: CustomAppBarView(title: 'Service Request'));
  }
}
