import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'employee.dart';
import 'employee_database.dart';

void main() {
  runApp(EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
        create: (context) => EmployeeProvider(),
        child: HomePage(),
      ),
    );
  }
}

class EmployeeProvider with ChangeNotifier {
  final EmployeeDatabase _database = EmployeeDatabase();
  List<Employee> employees = [];

  Future<void> refreshEmployees() async {
    employees = await _database.getEmployees();
    notifyListeners();
  }
}

class HomePage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeProvider>(context);
    provider.refreshEmployees();

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee CRUD'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: positionController,
              decoration: InputDecoration(labelText: 'Position'),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text;
              final position = positionController.text;

              if (name.isNotEmpty && position.isNotEmpty) {
                await provider._database.insertEmployee(Employee(
                  id: 1,
                  name: name,
                  position: position,
                ));
                provider.refreshEmployees();
                nameController.clear();
                positionController.clear();
              }
            },
            child: Text('Add Employee'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.employees.length,
              itemBuilder: (context, index) {
                final employee = provider.employees[index];
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text(employee.position),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await provider._database.deleteEmployee(employee.id);
                      provider.refreshEmployees();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}