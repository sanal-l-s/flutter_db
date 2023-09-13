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
  final TextEditingController updateNameController = TextEditingController();
  final TextEditingController updatePositionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmployeeProvider>(context);
    provider.refreshEmployees();

    return Scaffold(
      appBar: AppBar(
        title: Text('Employee '),
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
                  // id: 1,
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // When edit button is pressed, show edit dialog
                          _showEditDialog(context, provider, employee);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await provider._database.deleteEmployee(employee.id!);
                          provider.refreshEmployees();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  // Function to show the edit dialog
  Future<void> _showEditDialog(BuildContext context, EmployeeProvider provider, Employee employee) async {
    updateNameController.text = employee.name;
    updatePositionController.text = employee.position;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Employee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: updateNameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: updatePositionController,
                decoration: InputDecoration(labelText: 'Position'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                updateNameController.clear();
                updatePositionController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updatedName = updateNameController.text;
                final updatedPosition = updatePositionController.text;

                if (updatedName.isNotEmpty && updatedPosition.isNotEmpty) {
                  final updatedEmployee = Employee(
                    id: employee.id,
                    name: updatedName,
                    position: updatedPosition,
                  );

                  await provider._database.updateEmployee(updatedEmployee);
                  provider.refreshEmployees();

                  updateNameController.clear();
                  updatePositionController.clear();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}