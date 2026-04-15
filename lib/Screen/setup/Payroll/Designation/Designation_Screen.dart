import 'package:demo_distribution/Provider/setup/Designation_provider/Designation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesignationScreen extends StatefulWidget {
  const DesignationScreen({super.key});

  @override
  State<DesignationScreen> createState() => _DesignationScreenState();
}

class _DesignationScreenState extends State<DesignationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<DesignationProvider>(context, listen: false).fetchDesignation();
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: Text("Designation"),),
      body: Consumer<DesignationProvider>(builder: (context,provider,child){
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (provider.error.isNotEmpty) {
          return Center(child: Text(provider.error));
        }
        return ListView.builder(
          itemCount: provider.designation.length,
            itemBuilder: (context,index){
              final designation=provider.designation[index];
              return ListTile(
                title: Text(designation.name),
                subtitle: Text("ID: ${designation.id}"),
              );
            });

      })
    );
  }
}
