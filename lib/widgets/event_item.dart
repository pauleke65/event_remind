import 'package:event_remind/views/view_event.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EventItem extends StatefulWidget {
  const EventItem({
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
  _EventItemState createState() => _EventItemState();
}

class _EventItemState extends State<EventItem> {
  String deleteEvent = '''
mutation deleteEvent(\$id: Int!) {
  delete_events_by_pk(id: \$id) {
    name
    id
  }
}


  ''';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Mutation(
        options: MutationOptions(
          document: gql(deleteEvent),
          update: (GraphQLDataProxy cache, QueryResult result) {
            return cache;
          },
          onCompleted: (dynamic resultData) {
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
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ViewEvent(
                            id: widget.id,
                            name: widget.name,
                            speaker: widget.speaker,
                            url: widget.url,
                            date: widget.date,
                            time: widget.time,
                            venue: widget.venue,
                          )));
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: Text('Confirm Delete'),
                      content: Text(
                          "Are you sure you want to delete '${widget.name}'"),
                      elevation: 1,
                      actions: [
                        TextButton(
                          onPressed: () {
                            runMutation({"id": widget.id});
                            Navigator.pop(context);
                          },
                          child: const Text('Yes'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('No'),
                        ),
                      ],
                    );
                  });
            },
            child: Container(
              width: width * 0.85,
              height: 200,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.url,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                        height: 70,
                        width: width,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "On ${widget.date} at ${widget.time}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
          );
        });
  }
}
