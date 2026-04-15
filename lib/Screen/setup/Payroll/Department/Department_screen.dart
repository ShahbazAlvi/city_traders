import 'package:demo_distribution/Provider/setup/Department_provider/DepartmentProvider.dart';
import 'package:demo_distribution/model/setup/payroll/Department.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      Provider.of<DepartmentProvider>(context, listen: false).FetchDepartment();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Department"),),
      body: Consumer<DepartmentProvider>(builder: (context,provider,child){
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(child: Text(provider.error));
        }
        return ListView.builder(
          itemCount: provider.department.length,
            itemBuilder: (context,index){
            final department = provider.department[index];
            return ListTile(
              title: Text(department.name),
              subtitle: Text("ID: ${department.id}"),
            );

        });

      }),
    );

  }
}
