import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../controllers/event_controller.dart';
import '../../../models/event.dart';
import '../../../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event?.name ?? '');
    _dateController = TextEditingController(text: widget.event?.date ?? '');
    _locationController = TextEditingController(text: widget.event?.location ?? '');
    _descriptionController = TextEditingController(text: widget.event?.description ?? '');
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
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                child: Text(widget.event == null ? 'Add Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}