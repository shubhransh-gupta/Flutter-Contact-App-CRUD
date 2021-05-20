import 'package:myproject/contacts_view_model.dart';
import 'package:myproject/features/contact-list.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => ContactsViewModel(),
      child: MaterialApp(
        title: 'Flutter Contact App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Contact App'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchController.addListener(() {
        if(searchController.text.isNotEmpty) {
          Provider.of<ContactsViewModel>(context, listen: false)
              .searchContact(searchController.text);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () async {
          try {
            Contact contact = await ContactsService.openContactForm();
            if(contact!=null){
              Provider.of<ContactsViewModel>(context, listen: false).fetchContacts();
            }
          } on FormOperationException catch (e) {
            switch (e.errorCode) {
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
                print(e.toString());
            }
          }
        },
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    labelText: 'Search Contact',
                    border: new OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: new BorderSide(
                            color: Theme.of(context).primaryColor)),
                    prefixIcon: Icon(Icons.search,
                        color: Theme.of(context).primaryColor)),
              ),
            ),
            Consumer<ContactsViewModel>(
              builder: (BuildContext context, model, Widget child) {
                if (model.state is ContactLoadingState)
                  return Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ));
                else if (model.state is ContactsLoadedState) {
                  return ContactsList(
                    reloadContacts: () {
                      Provider.of<ContactsViewModel>(context, listen: false)
                          .fetchContacts();
                    },
                    contacts: (model.state as ContactsLoadedState).contacts,
                  );
                } else if (model.state is FilteredContactState) {
                  return ContactsList(
                    reloadContacts: () {
                      Provider.of<ContactsViewModel>(context, listen: false)
                          .fetchContacts();
                    },
                    contacts: (model.state as FilteredContactState).contacts,
                  );
                } else {
                  return Container(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        (model.state as NoContactFoundState).message,
                        style: TextStyle(color: Colors.grey, fontSize: 20),
                      ));
                }
              },
            ),
          ],
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
