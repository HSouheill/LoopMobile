import 'package:flutter/material.dart';
import '../widgets/inactive_listing_card_list.dart'; // make sure this import exists

class InactiveListings extends StatefulWidget {
  const InactiveListings({super.key});

  @override
  State<InactiveListings> createState() => _InactiveListingsState();
}

class _InactiveListingsState extends State<InactiveListings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          title: Container(
            padding: const EdgeInsets.only(top: 15, left: 50),
            child: const Text(
              "Inactive Listings",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF82A6FF),
                  Color(0xFF487CFF),
                  Color(0xFF3770FF),
                  Color(0xFF0048FF),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          leading: Container(
            margin: const EdgeInsets.only(top: 15),
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xFF0048FF), width: 1),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0048FF),
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔎 Search Row
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.search_sharp, color: Color(0xFF0048FF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "Search ...",
                          hintStyle: TextStyle(
                            color: Color(0xFF0048FF),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Divider(
                  thickness: 1,
                  height: 1,
                  color: Color(0xFF0ACC00),
                ),
              ),

              const SizedBox(height: 20), // spacing before cards

              // Inactive Listings Cards
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Center(
                  child: InactiveListingCardList(
                    scrollDirection: Axis.vertical,
                    items: [
                      {
                        "daysLeft": "12",
                        "backgroundImage": "https://i.imgur.com/G5qWJ4p.jpeg",
                        "description": "Apartment in Achrafieh",
                        "price": "900",
                        "location": "Byblos Seaside",
                        "owner": "Mike D.",
                        "layoutType": "B",
                      },
                      {
                        "daysLeft": "8",
                        "backgroundImage": "https://i.imgur.com/UM9Z7xk.jpeg",
                        "description": "Studio in Hamra",
                        "price": "700",
                        "location": "Byblos Seaside",
                        "owner": "Mike D.",
                        "layoutType": "B",
                      },
                      {
                        "daysLeft": "20",
                        "backgroundImage": "https://i.imgur.com/6JfO9hZ.jpeg",
                        "description": "Duplex in Byblos",
                        "price": "1500",
                        "location": "Byblos Seaside",
                        "owner": "Mike D.",
                        "layoutType": "B",
                      },
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30), // extra space at bottom
            ],
          ),
        ),
      ),
    );
  }
}
