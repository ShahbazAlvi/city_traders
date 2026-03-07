import 'package:demo_distribution/Provider/setup/tax_types_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaxTypesScreen extends StatefulWidget {
  const TaxTypesScreen({super.key});

  @override
  State<TaxTypesScreen> createState() => _TaxTypesScreenState();
}

class _TaxTypesScreenState extends State<TaxTypesScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask((){
      Provider.of<TaxTypesProvider>(context, listen: false).fetchTax();

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tax Types"),
      ),
      body: SingleChildScrollView(
        child: Consumer<TaxTypesProvider>(builder: (context,provider,child){
          if(provider.isLoading){
            return  const Center(child: CircularProgressIndicator());
          }
          if (provider.taxList.isEmpty) {
            return const Center(child: Text("No Tax Found"));
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.taxList.length,
            itemBuilder: (context, index) {
              final tax = provider.taxList[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(tax.name),
                  subtitle: Text("Rate: ${tax.ratePercent}%"),
                  trailing: Icon(
                    tax.isActive == 1
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: tax.isActive == 1
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              );
            },
          );


        }),
      ),
    );
  }
}
