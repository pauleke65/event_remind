import 'package:event_remind/views/add_event.dart';
import 'package:event_remind/widgets/event_item.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getEvents = '''
  query getEvents {
  events(order_by: {date: asc}) {
    date
    id
    name
    speaker
    time
    url
    venue
  }
}
  ''';
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Query(
          options: QueryOptions(
            document: gql(getEvents),
          ),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.hasException) {
              return Center(child: Text(result.exception.toString()));
            }

            if (result.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            List events = result.data['events'];
            print(events.length);

            return Container(
              padding: EdgeInsets.only(
                left: 10,
                top: 30,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "All Events",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              size: 40,
                              color: Colors.teal,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          AddEvent()));
                            }),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    flex: 2,
                    child: ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (builder, index) {
                          return EventItem(
                            date: events[index]['date'],
                            id: events[index]['id'],
                            name: events[index]['name'],
                            speaker: events[index]['speaker'],
                            time: events[index]['time'],
                            url: events[index]['url'],
                            venue: events[index]['venue'],
                          );
                        }),
                  )
                ],
              ),
            );
          }),
    );
  }
}
