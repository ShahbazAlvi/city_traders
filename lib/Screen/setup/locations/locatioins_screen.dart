import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Provider/setup/location_provider.dart';



class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false)
          .getLocations();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Locations"),
      ),

      body: Consumer<LocationProvider>(
        builder: (context, provider, child) {

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.locationList.isEmpty) {
            return const Center(
              child: Text("No Locations Found"),
            );
          }

          return ListView.builder(
            itemCount: provider.locationList.length,
            itemBuilder: (context, index) {

              final location = provider.locationList[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(

                  title: Text(location.name),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        location.isActive == 1
                            ? "Active"
                            : "Inactive",
                        style: TextStyle(
                          color: location.isActive == 1
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}