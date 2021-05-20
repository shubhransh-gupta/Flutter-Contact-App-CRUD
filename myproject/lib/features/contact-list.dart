import 'package:myproject/app-contactclass.dart';
import 'package:flutter/material.dart';
import 'package:myproject/views/contact-details.dart';
import 'contact-avatar.dart';

class ContactsList extends StatelessWidget {
  final List<AppContact> contacts;
  final Function() reloadContacts;

  ContactsList({Key key, this.contacts, this.reloadContacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          AppContact contact = contacts[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => ContactDetails(
                        contact,
                        onContactUpdate: (AppContact _contact) {
                          reloadContacts();
                        },
                        onContactDelete: (AppContact _contact) {
                          Navigator.of(context).pop();
                          reloadContacts();
                        },
                      )));
            },
            title: Text(contact.info.displayName ?? ''),
            subtitle: Text(contact.info.phones.length > 0
                ? contact.info.phones.elementAt(0).value
                : ''),
            leading: ContactAvatar(contact, 36),
          );
        },
      ),
    );
  }
}
