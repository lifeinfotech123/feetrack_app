// import 'package:flutter/material.dart';

// import '../../../../core/constants/colors.dart';
// import '../../../ipd/presentation/screen/ipd_list_screen.dart';
// import '../../../opd/presentation/screen/opd_list_screen.dart';

// class VisitsScreen extends StatelessWidget {
//   const VisitsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         backgroundColor: backgroundColor,
//         appBar: AppBar(
//           backgroundColor: primaryColor,
//           elevation: 0,
//           title: const Text(
//             'My Visits',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           bottom: const TabBar(
//             indicatorColor: colorWhite,
//             indicatorWeight: 2,
//             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
//             tabs: [
//               Tab(text: 'OPD Visits'),
//               Tab(text: 'IPD Visits'),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             OpdListScreen(),
//             IpdListScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }
