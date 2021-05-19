import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:myproject/app-contactclass.dart';
import 'package:myproject/features/contact-avatar.dart';
import 'package:flutter/material.dart';

class ContactDetails extends StatefulWidget {
  ContactDetails(this.contact, {this.onContactUpdate, this.onContactDelete});

  final AppContact contact;
  final Function(AppContact) onContactUpdate;
  final Function(AppContact) onContactDelete;
  @override
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {

  @override
  Widget build(BuildContext context) {
    showDeleteAlertBox(){
    Widget cancelButton = TextButton(
      onPressed: (){        
         Navigator.of(context).pop();
        },
       child: Text('Cancel'),
       );
    Widget deleteButton= TextButton(
      style: TextButton.styleFrom(
      primary: Colors.white,
      backgroundColor: Colors.red,
      onSurface: Colors.redAccent,
      ),
      onPressed: () async {
      await ContactsService.deleteContact(widget.contact.info);
      widget.onContactDelete(widget.contact);
      Navigator.of(context).pop();
      },
      child: Text('Delete'),
      );
        
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.blueGrey,
      title: Text('Delete Contact'),
      content: Text('Are you sure to delete this contact ?'),
      actions: <Widget>[
        cancelButton,
        deleteButton
      ],
      );
      showDialog(
        context: context,
         builder: (BuildContext context){
           return alert;
         });
  }
   onActionUpdate() async{
       try{
          Contact updatedContact = await ContactsService.openExistingContact(widget.contact.info);
          setState(() {
            widget.contact.info=updatedContact;
          });
          widget.onContactUpdate(widget.contact);
          } on FormOperationException catch(e){
             switch(e.errorCode){
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
              print(e.toString());
             }
   }
   }
    return Scaffold(appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Contact Details'),
      ),
      /* floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
       floatingActionButton : FloatingActionButton(                                                       
                       onPressed: () {onActionUpdate(); },
                       backgroundColor: Theme.of(context).primaryColor,
                       child: Text("Update")
                       ),*/ 
          body: SafeArea(                     
          child: Column(
          children: <Widget>[
            Container(
              height: 180,
              decoration: BoxDecoration(color: Colors.grey[300]),
             
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Center(child: ContactAvatar(widget.contact, 100)),
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
               
                ],
              ),
            ),
            Expanded(
              child: ListView(shrinkWrap: true, children: <Widget>[
                ListTile(
                  title: Text("Name"),
                  trailing: Text(widget.contact.info.givenName ?? ""),
                ),
                ListTile(
                  title: Text("Family name"),
                  trailing: Text(widget.contact.info.familyName ?? ""),
                ),
                Column(
                  children: <Widget>[
                    ListTile(title: Text("Phones")),
                    Column(
                      children: widget.contact.info.phones
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(i.label ?? ""),
                              trailing: Text(i.value ?? ""),
                            ),
                          ),
                        )
                        .toList(),
                    )
                  ],
                )
              ]),
            )
          ],
        ),
      ),
       floatingActionButton: SpeedDial(
                child: Icon(Icons.account_box),
                children: [
                  SpeedDialChild(
                    child: Icon(Icons.account_circle_sharp),
                    label: "Update",
                    onTap: ()=> onActionUpdate()
                  ), 
                  SpeedDialChild(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.backspace_outlined),
                    label: "Delete",
                    onTap: ()=> showDeleteAlertBox()
                  ) 
                ],
              ),
    );
  }
}
  