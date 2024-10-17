import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'car_details_page.dart';

class CarListView extends StatefulWidget {
  final PocketBase pb;
  final String role;
  final VoidCallback? refreshCars; // Accept a callback to trigger external refresh

  CarListView({required Key key, required this.pb, required this.role, this.refreshCars})
      : super(key: key);

  @override
  CarListViewState createState() => CarListViewState();
}

class CarListViewState extends State<CarListView> {
  Future<List<RecordModel>>? _carListFuture;

  @override
  void initState() {
    super.initState();
    _refreshCars();
  }

  // Public method to refresh cars, can be called from outside
  void refreshCars() {
    setState(() {
      _refreshCars();
    });
  }

  void _refreshCars() {
    setState(() {
      _carListFuture = _fetchCars(); // Fetch fresh car data
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecordModel>>(
      future: _carListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No cars found'));
        }

        final NumberFormat numberFormat = NumberFormat('#,###', 'en_US');

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 3 / 4,
          ),
          padding: EdgeInsets.all(10.0),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final car = snapshot.data![index];
            String? imageUrl;

            if (car.data.containsKey('image') && car.data['image'] != null) {
              imageUrl = widget.pb.getFileUrl(car, car.data['image']).toString();
            }

            return Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsPage(
                        pb: widget.pb,
                        carRecord: car,
                        role: widget.role,
                      ),
                    ),
                  );

                  // If a car was updated, refresh the car list
                  if (result == true) {
                    refreshCars(); // Refresh cars after returning
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                height: 140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 140,
                                    color: Colors.grey[300],
                                    child: Center(child: Text('Image not available')),
                                  );
                                },
                              )
                            : Container(
                                height: 140,
                                color: Colors.grey[300],
                                child: Center(child: Text('No Image')),
                              ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        car.data['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Brand: ${car.data['brand']}',
                        style: TextStyle(color: Colors.blueGrey[600]),
                      ),
                      Text(
                        'Model: ${car.data['model']}',
                        style: TextStyle(color: Colors.blueGrey[600]),
                      ),
                      Text(
                        'Year: ${car.data['year']}',
                        style: TextStyle(color: Colors.blueGrey[600]),
                      ),
                      Text(
                        'Horsepower: ${car.data['horsepower']} HP',
                        style: TextStyle(color: Colors.blueGrey[600]),
                      ),
                      Spacer(),
                      Text(
                        'Price: ${numberFormat.format(car.data['price'])} Baht',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fetch the list of cars from PocketBase
  Future<List<RecordModel>> _fetchCars() async {
    try {
      final records = await widget.pb.collection('cars').getFullList(
        sort: '-created',
      );
      return records;
    } catch (e) {
      print('Error fetching cars: $e');
      return [];
    }
  }
}
