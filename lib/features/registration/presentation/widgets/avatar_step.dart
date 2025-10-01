import 'package:discover/config/themes/app_theme.dart';
import 'package:flutter/material.dart';
import '../widgets/step_scaffold.dart';

class AvatarStep extends StatelessWidget {
  final String? selectedKey;
  final ValueChanged<String> onSelect;

  const AvatarStep({
    super.key,
    required this.selectedKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {

    //Close keyboard if open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

    final avatars = <String>[
      'assets/avatar/avatar_1.png',
      'assets/avatar/avatar_2.png',
      'assets/avatar/avatar_3.png',
      'assets/avatar/avatar_4.png',
      'assets/avatar/avatar_5.png',
      'assets/avatar/avatar_6.png',
      'assets/avatar/avatar_7.png',
      'assets/avatar/avatar_8.png',
      'assets/avatar/avatar_9.png',
      'assets/avatar/avatar_10.png',
      'assets/avatar/avatar_11.png',
      'assets/avatar/avatar_12.png',
    ];

    final primary = AppTheme.primaryColor;

    return StepScaffold(
      title: 'Scegli il tuo avatar',
      child: LayoutBuilder(
        builder: (context, c) {
          final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
          final maxWidth = c.maxWidth;
          final cols = isPortrait ? 3 : 5;
          final spacing = 16.0;
          final cellSide = ((maxWidth - (cols - 1) * spacing) / cols).clamp(88.0, 140.0);
          final avatarRadius = (cellSide / 2) - 6; // - padding

          return Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing,
              runSpacing: spacing,
              children: avatars.map((path) {
                final isSel = path == selectedKey;
                return Semantics(
                  button: true,
                  selected: isSel,
                  label: 'Avatar ${avatars.indexOf(path) + 1}',
                  child: SizedBox(
                    width: cellSide,
                    height: cellSide,
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => onSelect(path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel ? primary : Colors.transparent,
                              width: 4,
                            ),
                            boxShadow: [
                              if (isSel)
                                BoxShadow(
                                  color: primary.withOpacity(0.25),
                                  blurRadius: 16,
                                ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: primary.withOpacity(0.15),
                            backgroundImage: AssetImage(path),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
