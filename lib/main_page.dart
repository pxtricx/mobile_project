import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'add_car_page.dart';
import 'car_list_view.dart';
import 'custom_app_bar.dart';

class MainPage extends StatefulWidget {
  final String role;
  final PocketBase pb;

  MainPage({required this.role, required this.pb});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<CarListViewState> _carListViewKey = GlobalKey<CarListViewState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'CarsListing', pb: widget.pb),
      body: Container(
        color: Colors.white,
        child: widget.role == 'admin'
            ? AdminFunctions(pb: widget.pb, refreshCars: _refreshCarList)
            : MemberFunctions(pb: widget.pb, refreshCars: _refreshCarList),
      ),
      floatingActionButton: widget.role == 'admin'
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCarPage(pb: widget.pb),
                  ),
                );
                // Refresh the car list if a car was added
                if (result == true) {
                  _refreshCarList(); // Trigger the refresh
                }
              },
              backgroundColor: Colors.teal[400],
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  // Refresh the car list by calling the method on the CarListView
  void _refreshCarList() {
    _carListViewKey.currentState?.refreshCars(); // Trigger the refresh in CarListView
  }
}

class AdminFunctions extends StatelessWidget {
  final PocketBase pb;
  final VoidCallback refreshCars;

  AdminFunctions({required this.pb, required this.refreshCars});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text('Administrator Permit', style: TextStyle(fontSize: 24)),
        SizedBox(height: 20),
        Expanded(
          child: CarListView(
            key: GlobalKey(), // Ensure the CarListView is properly refreshed
            pb: pb,
            role: 'admin',
            refreshCars: refreshCars, // Pass the refresh function down
          ),
        ),
      ],
    );
  }
}

class MemberFunctions extends StatelessWidget {
  final PocketBase pb;
  final VoidCallback refreshCars;

  MemberFunctions({required this.pb, required this.refreshCars});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CarListView(
        key: GlobalKey(), // Ensure the CarListView is properly refreshed
        pb: pb,
        role: 'member',
        refreshCars: refreshCars, // Pass the refresh function down
      ),
    );
  }
}
