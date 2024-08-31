
import 'package:flutter/material.dart';

import 'genel.dart';

class Widgets {

  static Widget Progress() {
    return Container(
        height: Genel.yukseklik,
        width: Genel.genislik,
        color: Colors.black87,
        child: Center(
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                elevation: 8,
                child: Container(
                    padding: EdgeInsets.fromLTRB(4, 4, 16, 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            child: Image.asset(
                          "assets/images/load.gif",
                          width: 70,
                        )),

                      ],
                    )))));
  }

  static Widget CardTasarimi()
  {
    return
      ListTile(
        subtitle:  new Row(
          children: [
            Expanded(child:
            Card(
              // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              // Set the clip behavior of the card
              clipBehavior: Clip.antiAliasWithSaveLayer,
              // Define the child widgets of the card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels

                  Image.asset(
                    'assets/images/suleyman.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Add a container with padding that contains the card's title, text, and buttons
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Display the card's title using a font size of 24 and a dark grey color
                        Text(
                          "Süleyman",
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.grey[800],
                          ),
                        ),
                        // Add a space between the title and the text
                        Container(height: 10),
                        // Display the card's text using a font size of 15 and a light grey color
                        Text(
                          "Turan",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                        // Add a row with two buttons spaced apart and aligned to the right side of the card
                        Row(
                          children: <Widget>[
                            // Add a spacer to push the buttons to the right side of the card
                            const Spacer(),
                            // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.transparent,
                              ),
                              child: const Text(
                                "SHARE",
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                              onPressed: () {},
                            ),
                            // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.transparent,
                              ),
                              child: const Text(
                                "EXPLORE",
                                style: TextStyle(color: Colors.deepOrangeAccent),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Add a small space between the card and the next widget
                  Container(height: 5),
                ],
              ),
            ))
          ],
        ),
      );

  }




  static // Function to build a dropdown widget with a black underline,
  // white text when closed, and black text when opened
  Widget buildGenderDropdown(
      BuildContext context,
      List<String> genderOptions,
      String? selectedGender,
      ValueChanged<String?> onChanged,
      ) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      hint: Text('Cinsiyet Seçin', style: TextStyle(color: Colors.white)),
      icon: Icon(Icons.arrow_downward, color: Colors.white),
      dropdownColor: Colors.white, // Açıldığında arka plan beyaz
      decoration: InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Normal alt çizgi siyah
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // Odaklandığında siyah alt çizgi
        ),
      ),
      style: TextStyle(color: Colors.white), // Dropdown kapalıyken beyaz metin
      items: genderOptions.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Row(
            children: <Widget>[
              Icon(
                gender == 'Erkek' ? Icons.male : gender == 'Kadın' ? Icons.female : Icons.transgender,
                color: gender == 'Erkek' ? Colors.blue : gender == 'Kadın' ? Colors.pink : Colors.purple,
              ),
              SizedBox(width: 8),
              Text(gender, style: TextStyle(color: Colors.black)), // Açıldığında siyah metin
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

}
