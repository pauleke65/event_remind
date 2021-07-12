import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:async';
import '../controllers/image_controller.dart';
import 'package:get/get.dart';
import 'dart:io';

class AddEvent extends StatefulWidget {
  const AddEvent({Key key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController venueController = TextEditingController();
  TextEditingController speakerController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  String imageURL;

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
        selectedDate = picked;
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  bool loading = false;

  String addEvent = '''
  mutation addEvents(\$object: events_insert_input = {}) {
  insert_events_one(object: \$object) {
    id
    name
  }
}
''';

  @override
  Widget build(BuildContext context) {
    dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
    timeController.text = "${selectedTime.format(context)}";
    final imageController = Get.put(ImageController());

    return Scaffold(
      body: Mutation(
          options: MutationOptions(
            document: gql(addEvent),
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
                            "Create A New Event",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 38,
                            ),
                          ),
                          GetX<ImageController>(builder: (controller) {
                            return Container(
                              height: 200,
                              color: Colors.grey,
                              margin: EdgeInsets.all(20),
                              child: controller.imagePath == null
                                  ? Container()
                                  : Image.file(
                                      File(controller.imagePath.toString())),
                            );
                          }),
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
                                await imageController.getImage();
                                setState(() {
                                  filePath = imageController.imagePath.value;
                                });
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
                                await uploadFile(filePath);
                                runMutation({
                                  "object": {
                                    "date": dateController.text,
                                    "name": nameController.text,
                                    "venue": venueController.text,
                                    "speaker": speakerController.text,
                                    "url": imageURL,
                                    "time": timeController.text
                                  }
                                });
                              },
                              child: Text("Add New Event"),
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
