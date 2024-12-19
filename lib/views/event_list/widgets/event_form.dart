import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl/intl.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event.dart';
import '../../../services/auth_service.dart';
import '../../../shared/widgets/custom_widgets.dart';

class EventForm extends StatefulWidget {
  final Event? event;
  final Function(Event) onSave;

  EventForm({this.event, required this.onSave});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  final EventController _controller = EventController();
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _dateController = TextEditingController(text: widget.event?.date ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
    if (widget.event != null) {
      _selectedDate = DateTime.parse(widget.event!.date);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AuthTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _dateController,
                labelText: 'Date',
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _locationController,
                labelText: 'Location',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              AuthTextField(
                controller: _descriptionController,
                labelText: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              AuthButton(
                text: widget.event == null ? 'Add Event' : 'Update Event',
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    firebase_auth.User? currentUser = _authService.getCurrentUser();
                    if (currentUser != null) {
                      if (widget.event == null) {
                        // Add new event
                        Event event = Event(
                          id: '', // Temporary ID, will be replaced by Firestore
                          name: _nameController.text,
                          date: _dateController.text,
                          location: _locationController.text,
                          description: _descriptionController.text,
                          userId: currentUser.uid,
                        );
                        await _controller.addEvent(event);
                        widget.onSave(event);
                      } else {
                        // Update existing event
                        Event updatedEvent = Event(
                          id: widget.event!.id,
                          name: _nameController.text,
                          date: _dateController.text,
                          location: _locationController.text,
                          description: _descriptionController.text,
                          userId: widget.event!.userId,
                        );
                        await _controller.updateEvent(updatedEvent);
                        widget.onSave(updatedEvent);
                      }
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}