import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAbout(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  if(context.mounted){
    showDialog(
      context: context, 
      builder: (context)=>AlertDialog(
        title: Text('about'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon.png',
              width: 100,
            ),
            const SizedBox(height: 10,),
            Text(
              'Server Express',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 3,),
            Text(
              'v${packageInfo.version}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[400]
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: (){
                final url=Uri.parse('https://github.com/Zhoucheng133/Server-Express');
                launchUrl(url);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.github,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'projectURL'.tr,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: ()=>showLicensePage(
                applicationName: 'Server Express',
                applicationVersion: packageInfo.version,
                context: context
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.certificate,
                      size: 15,
                    ),
                    const SizedBox(width: 5,),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        'license'.tr,
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: ()=>Navigator.pop(context), 
            child: Text("ok".tr)
          )
        ],
      )
    );
  }
}