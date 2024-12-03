import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_data_table/stemious_data_table.dart';
import 'package:json_data_table/classes/stemious_data_table_column.dart';

class CustomDataTable extends StatefulWidget {
  const CustomDataTable({Key? key}) : super(key: key);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  late List<Map<String, dynamic>> dataToExport;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Data Table'),
        backgroundColor: const Color.fromARGB(255, 229, 166, 166),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('ExperimentCards').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Firestore error: ${snapshot.error}');
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          final List<QueryDocumentSnapshot> documents = snapshot.data!.docs;
          dataToExport = documents.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Format timestamp if present
            if (data['timestamp'] != null && data['timestamp'] is Timestamp) {
              // Convert Firestore Timestamp to DateTime
              data['timestamp'] = (data['timestamp'] as Timestamp);
            }
            return data;
          }).toList();

          if (dataToExport.isEmpty) {
            return const Center(child: Text("No Data Available"));
          }

          return SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: StemiousDataTable.data(
                // StemiousColumnHeaderTheme(
                //   headerColor: Colors.purple,
                // ),
                // StemiousColumnDataTheme(
                //   cellColor: colors.blue,
                // ),
                columnConfig: [
                  StemiousColumn(
                    label: 'Experiment Name',
                    dataKey: 'experimentLongName',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      borderRadius: BorderRadius.circular(4),

                    cellColor: Colors.blue,

                      dataAlignment: Alignment.centerLeft,
                      textStyleBuilder: (data, style) {
                        if (data["experimentLongName"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Small Name',
                    dataKey: 'smallName',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.centerLeft,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["smallName"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Status',
                    dataKey: 'status',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 100,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["status"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Subject',
                    dataKey: 'subject',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 100,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["subject"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Complexity',
                    dataKey: 'complexity',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 100,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["complexity"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Created By',
                    dataKey: 'createdByUserName',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.centerLeft,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["createdByUserName"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Timestamp',
                    dataKey: 'timestamp',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["timestamp"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Sensor',
                    dataKey: 'sensor',
                    columnHeaderTheme: StemiousColumnHeaderTheme(

                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                      cellColor: Colors.blue,
                      textStyleBuilder: (data, style) {
                        if (data["timestamp"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                  StemiousColumn(
                    label: 'Action',
                    dataKey: 'action',
                    columnHeaderTheme: StemiousColumnHeaderTheme(                     
                      headerColor: Colors.purple,
                    ),
                    initialWidth: 200,
                    columnDataTheme: StemiousColumnDataTheme(
                      margin: const EdgeInsets.all(6),
                      dataAlignment: Alignment.center,
                    cellColor: Colors.blue,

                      textStyleBuilder: (data, style) {
                        if (data["timestamp"] == "stem") {
                          return style?.copyWith(fontWeight: FontWeight.bold);
                        }
                        return style;
                      },
                    ),
                  ),
                ],
                data: dataToExport,
              ),
            ),
          );
        },
      ),
    );
  }
}
