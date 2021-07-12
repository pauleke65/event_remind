import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class ViewEvent extends StatefulWidget {
  const ViewEvent({
    Key key,
    this.date,
    this.id,
    this.name,
    this.speaker,
    this.time,
    this.url,
    this.venue,
  }) : super(key: key);

  final String date;
  final int id;
  final String name;
  final String speaker;
  final String time;
  final String url;
  final String venue;

  @override
  _ViewEventState createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController venueController = TextEditingController();
  TextEditingController speakerController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String imageURL;
  String imagePath;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String filePath;

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: 'gs://event-remind.appspot.com/');

  Future<void> uploadFile(String filePath) async {
    File file = File(filePath);
    String ref = 'uploads/${filePath.split('/').last}';
    try {
      await firebase_storage.FirebaseStorage.instance.ref(ref).putFile(file);

      String url = (await firebase_storage.FirebaseStorage.instance
              .ref(ref)
              .getDownloadURL())
          .toString();

      setState(() {
        imageURL = url;
      });
    } on firebase_core.FirebaseException catch (e) {
      print(e);

      // e.g, e.code == 'canceled'
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime)
      setState(() {
        timeController.text = "${picked.format(context)}";
      });
  }

  Future getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  bool loading = false;
  int id;

  void initState() {
    super.initState();

    setState(() {
      id = widget.id;
      nameController.text = widget.name;
      speakerController.text = widget.speaker;
      imageURL = widget.url;
      dateController.text = widget.date;
      timeController.text = widget.time;
      venueController.text = widget.venue;
    });
  }

  String updateEvent = '''
mutation updateEvent(\$id: Int!, \$_set: events_set_input = {}) {
  update_events_by_pk(pk_columns: {id: \$id}, _set: \$_set) {
    id
    name
  }
}

''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Mutation(
          options: MutationOptions(
            document: gql(updateEvent),
            update: (GraphQLDataProxy cache, QueryResult result) {
              return cache;
            },
            onCompleted: (dynamic resultData) {
              setState(() {
                loading = false;
              });
              Navigator.pop(context);
              print(resultData);
            },
            onError: (OperationException error) {
              setState(() {
                loading = false;
              });
              print(error);
            },
          ),
          builder: (
            RunMutation runMutation,
            QueryResult result,
          ) {
            return loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding: EdgeInsets.only(
                      left: 15,
                      right: 20,
                      top: 50,
                    ),
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Update Event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                            ),
                          ),
                          Container(
                            height: 200,
                            color: Colors.grey,
                            margin: EdgeInsets.all(20),
                            child: imagePath == null
                                ? Image.network(imageURL)
                                : Image.file(File(imagePath.toString())),
                          ),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                                labelText: "Event Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                )),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: venueController,
                            decoration: InputDecoration(
                                labelText: "Event Venue",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                )),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: speakerController,
                            decoration: InputDecoration(
                                labelText: "Event Speaker",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(
                                    width: 2,
                                  ),
                                )),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            controller: dateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: "Event Date",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                ),
                              ),
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 12.0),
                                child: IconButton(
                                  icon: Icon(Icons.calendar_today_rounded),
                                  onPressed: () => _selectDate(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextField(
                            readOnly: true,
                            controller: timeController,
                            decoration: InputDecoration(
                              labelText: "Event Time",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  width: 2,
                                ),
                              ),
                              suffixIcon: Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 12.0),
                                child: IconButton(
                                  icon: Icon(Icons.schedule_rounded),
                                  onPressed: () => _selectTime(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: MaterialButton(
                              onPressed: () async {
                                await getImage();
                              },
                              child: Text("Upload Image"),
                              color: Colors.white,
                              textColor: Colors.blue,
                              height: 60,
                              minWidth: double.infinity,
                              shape: StadiumBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: MaterialButton(
                              onPressed: () async {
                                setState(() {
                                  loading = true;
                                });
                                imagePath == null
                                    ? print('')
                                    : await uploadFile(filePath);
                                runMutation({
                                  "id": id,
                                  "_set": {
                                    "date": dateController.text,
                                    "name": nameController.text,
                                    "venue": venueController.text,
                                    "speaker": speakerController.text,
                                    "url": imageURL,
                                    "time": timeController.text
                                  }
                                });
                              },
                              child: Text("Save Changes"),
                              color: Colors.blue,
                              textColor: Colors.white,
                              height: 60,
                              minWidth: double.infinity,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          }),
    );
  }
}
