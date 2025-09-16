import 'package:eps_client/src/utils/gap.dart';
import 'package:flutter/material.dart';
import '../utils/dimens.dart';

class CustomAppBarView extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Color? backgroundColor;
  const CustomAppBarView({super.key, required this.title, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      leadingWidth: 40,
      title: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context, true);
            },
            child: Icon(Icons.arrow_back_ios_new,size: 16,),
          ),
          20.hGap,
          Text(title ?? "" , style: const TextStyle(fontWeight: FontWeight.w500,fontSize: kTextRegular18),),
          const Spacer(),
          const Text(''),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}
