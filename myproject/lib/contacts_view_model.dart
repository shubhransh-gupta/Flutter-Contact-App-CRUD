import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app-contactclass.dart';

// noContactsFoundState, loading, filterContacts, contactsLoaded
abstract class ContactState {}

class NoContactFoundState extends ContactState {
  final String message;

  NoContactFoundState(this.message);
}

class ContactLoadingState extends ContactState {}

class FilteredContactState extends ContactState {
  final List<AppContact> contacts;

  FilteredContactState(this.contacts);
}

class ContactsLoadedState extends ContactState {
  final List<AppContact> contacts;

  ContactsLoadedState(this.contacts);
}

class ContactsViewModel extends ChangeNotifier {
  ContactState state;
  List<AppContact> _contacts = [];

  ContactsViewModel() {
    state = ContactLoadingState();
    _notify();
    fetchContacts();
  }

  Future<void> _getPermissions() async {
    if (await Permission.contacts.request().isGranted) {
      print('Permission granted');
    }
  }

  Future<void> fetchContacts() async {
    //getPermissions
    // fetch contacts from contacts service
    // if contacts present
    //   set the state to contactsLoadedState
    // else
    // set the state to NoContactFoundState
    await _getPermissions();
    List colors = [Colors.green, Colors.indigo, Colors.yellow, Colors.orange];
    int colorIndex = 0;
    _contacts = (await ContactsService.getContacts()).map((contact) {
      Color baseColor = colors[colorIndex];
      colorIndex++;
      if (colorIndex == colors.length) {
        colorIndex = 0;
      }
      return new AppContact(info: contact, color: baseColor);
    }).toList();
    if (_contacts.isNotEmpty) {
      state = ContactsLoadedState(_contacts);
    } else {
      state = NoContactFoundState('No contacts found');
    }
    _notify();
  }

  void searchContact(String keyword) {
    // keyword ! = null then search
    // get the loaded list and retain contacts which matched the keyword
    //  if no retained contact
    // set the state to NoContactFoundState
    // else
    //   state = FilteredContactState

    String flattenPhoneNumber(String phoneStr) {
      return phoneStr.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
        return m[0] == "+" ? "+" : "";
      });
    }

    List<AppContact> _filteredContacts = [];
    _filteredContacts.addAll(_contacts);
    if (keyword != null && keyword.isNotEmpty) {
      _filteredContacts.retainWhere((contact) {
        String searchTerm = keyword.toLowerCase();
        String searchTermFlatten = flattenPhoneNumber(searchTerm);
        String contactName = contact.info.displayName?.toLowerCase();
        bool nameMatches = contactName?.contains(searchTerm);
        if (nameMatches == true) {
          return true;
        }

        if (searchTermFlatten.isEmpty) {
          return false;
        }

        var phone = contact.info.phones.firstWhere((phn) {
          String phnFlattened = flattenPhoneNumber(phn.value);
          return phnFlattened.contains(searchTermFlatten);
        }, orElse: () => null);

        return phone != null;
      });
    }
    if (_filteredContacts.isNotEmpty) {
      state = FilteredContactState(_filteredContacts);
    } else {
      state = NoContactFoundState('No Search Results');
    }
    _notify();
  }

  void _notify() {
    notifyListeners();
  }
}
