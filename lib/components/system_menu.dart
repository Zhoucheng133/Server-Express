import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:server_express/components/dialogs/about.dart';

class SystemMenu extends StatefulWidget {
  const SystemMenu({super.key});

  @override
  State<SystemMenu> createState() => _SystemMenuState();
}

class _SystemMenuState extends State<SystemMenu> {
  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: "Server Express", 
          menus: [
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: "About Server Express".tr,
                  onSelected: (){
                    showAbout(context);
                  }
                )
              ]
            ),
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  enabled: true,
                  type: PlatformProvidedMenuItemType.hide,
                ),
                PlatformProvidedMenuItem(
                  enabled: true,
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ]
            )
          ]
        ),
        PlatformMenu(
          label: "Edit".tr,
          menus: [
            PlatformMenuItem(
              label: "Copy".tr,
              onSelected: (){
                final focusedContext = FocusManager.instance.primaryFocus?.context;
                if (focusedContext != null) {
                  Actions.invoke(focusedContext, CopySelectionTextIntent.copy);
                }
              }
            ),
            PlatformMenuItem(
              label: "Paste".tr,
              onSelected: (){
                final focusedContext = FocusManager.instance.primaryFocus?.context;
                if (focusedContext != null) {
                  Actions.invoke(focusedContext, const PasteTextIntent(SelectionChangedCause.keyboard));
                }
              },
            ),
            PlatformMenuItem(
              label: "Select All".tr,
              onSelected: (){
                final focusedContext = FocusManager.instance.primaryFocus?.context;
                if (focusedContext != null) {
                  Actions.invoke(focusedContext, const SelectAllTextIntent(SelectionChangedCause.keyboard));
                }
              }
            )
          ]
        ),
        PlatformMenu(
          label: "Window".tr, 
          menus: [
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  enabled: true,
                  type: PlatformProvidedMenuItemType.minimizeWindow,
                ),
                PlatformProvidedMenuItem(
                  enabled: true,
                  type: PlatformProvidedMenuItemType.toggleFullScreen,
                )
              ]
            )
          ]
        )
      ]
    );
  }
}