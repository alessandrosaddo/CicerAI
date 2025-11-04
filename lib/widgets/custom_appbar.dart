import 'package:flutter/material.dart';
import 'package:cicer_ai/themes/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {

    // Controlla se il tema attuale è chiaro o scuro
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Colori dinamici per il titolo
    final cicerColor = isLight ? AppColors.lightText : AppColors.darkText;
    final aiColor = isLight ? AppColors.lightPrimary : AppColors.darkPrimary;


    return AppBar(
      elevation: 0.5,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top:10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'images/cicer.png',
              height: 48,
            ),
            const SizedBox(width: 10),
            RichText(
                text: TextSpan(
                  style: GoogleFonts.nunito(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: "Cicer", style: TextStyle(color: cicerColor)),
                    TextSpan(text: "AI", style: TextStyle(color: aiColor)),
                  ],
                )
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70);
}
