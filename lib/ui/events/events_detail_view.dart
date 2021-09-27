import 'package:campus_mobile_experimental/core/models/events.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/event_time.dart';
import 'package:campus_mobile_experimental/ui/common/image_loader.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({Key? key, required this.data}) : super(key: key);
  final EventModel data;
  @override
  Widget build(BuildContext context) {
    return ContainerView(
      // height: MediaQuery.of(context).size.height,
      //   width: MediaQuery.of(context).size.width,

      // // child: SingleChildScrollView (
      //   child: buildDetailView(context),
      // // )

      // child: ListView(
      //   // physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        child: buildDetailView(context),
      // ),
    );
  }

  Widget buildDetailView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // return Scaffold(
    //   resizeToAvoidBottomInset: true,
    //   body: SingleChildScrollView(
    //     child: Container(
    //       constraints: BoxConstraints(
    //         maxHeight: height,
    //       ),
    //       child: Stack(
    //         children: [
    //           Flexible(
    //             child: Container(
    //               height: MediaQuery.of(context).size.height * 0.33,
    //               decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                   fit: BoxFit.fill,
    //                   image: NetworkImage(data.imageHQ!),
    //                 ),
    //               ),
    //             ),
    //           ),
    //           Container(
    //             height: MediaQuery.of(context).size.height * 0.66,
    //             margin: EdgeInsets.only(top: height * 0.32),
    //             decoration: BoxDecoration(
    //                 color: Colors.white,
    //                 borderRadius: BorderRadius.only(
    //                   topRight: Radius.circular(10.0),
    //                   topLeft: Radius.circular(10.0),
    //                 )),
    //             child: Center(
    //               child: Container(
    //                 width: width * 0.85,
    //                 child: Column(
    //                   children: [
    //                     Icon(Icons.keyboard_arrow_down, size: 30, color: Theme.of(context).primaryColor,),
    //                     Text(
    //                       data.title!,
    //                       textAlign: TextAlign.center,
    //                       style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.w500),
    //                       // style: Theme.of(context).textTheme.headline6,
    //                     ),
    //                     Padding(padding: EdgeInsets.only(top: 10.0),),
    //                     data.location != null && data.location!.isNotEmpty
    //                         ? LinkifyWithCatch(
    //                       text: "Where: " + data.location!,
    //                       looseUrl: true,
    //                       style: TextStyle(fontSize: 16, height: 1.3, color: Theme.of(context).primaryColor),
    //                       textAlign: TextAlign.center,
    //                     )
    //                         : Container(),
    //                     Padding(padding: EdgeInsets.only(top: 10.0),),
    //                     Center(child: EventTime(data: data)),
    //                     data.description != null && data.description!.isNotEmpty
    //                         ? Padding(
    //                       padding: const EdgeInsets.all(20.0),
    //                       child: LinkifyWithCatch(
    //                         text: data.description,
    //                         style: TextStyle(fontSize: 16, height: 1.3),
    //                       ),
    //                     )
    //                         : Container(),
    //                     data.link != null && data.link!.isNotEmpty
    //                         ? LearnMoreButton(link: data.link)
    //                         : Container(),
    //                   ],
    //                 ),
    //               ),
    //             ),
    //           )
    //       ]
    //       ),
    //     ),
    //   ),
    // );


    return ListView(
      children: [
        Container(
          width: width,
          height: height * 0.33,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(data.imageHQ!),
            )
          ),
        ),
        Flexible(
          child: Container(
            // width: width * 0.5,
            // height: height * 0.66,
            // margin: EdgeInsets.only(top: 10.0),
            color: Colors.blue,
            child: Center(
              child: Container(
                width: width * 0.8,
               color: Colors.white,
    child: Column(
                    children: [
                      Icon(Icons.keyboard_arrow_down, size: 30, color: Theme.of(context).primaryColor,),
                      Text(
                        data.title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.w500),
                        // style: Theme.of(context).textTheme.hev adline6,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0),),
                      data.location != null && data.location!.isNotEmpty
                          ? LinkifyWithCatch(
                        text: "Where: " + data.location!,
                        looseUrl: true,
                        style: TextStyle(fontSize: 16, height: 1.3, color: Theme.of(context).primaryColor),
                        textAlign: TextAlign.center,
                      )
                          : Container(),
                      Padding(padding: EdgeInsets.only(top: 10.0),),
                      Center(child: EventTime(data: data)),
                      data.description != null && data.description!.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                           data.description!,
                          style: TextStyle(fontSize: 16, height: 1.3),
                        ),
                      )
                          : Container(),
                      data.link != null && data.link!.isNotEmpty
                          ? LearnMoreButton(link: data.link)
                          : Container(),
                    ],
                  ),
              ),
            ),

          ),
        )
      ],
    );
      // Container(
      //   width: width,
      //   // height: height - 10,
      //   // color: Colors.green,
      //   child: new Column(
      //     children: <Widget>[
      //      new Container(
      //        height:  MediaQuery.of(context).size.height * 0.33 ,
      //        decoration: BoxDecoration(
      //          color: Colors.green,
      //          image: DecorationImage(
      //            fit: BoxFit.fill,
      //            image: NetworkImage(data.imageHQ!),
      //          ),
      //        ),
      //      ),
      //       Container(
      //         //color: Colors.blue,
      //         width: width,
      //         height: height * 0.6,
      //         decoration: BoxDecoration( borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)), color: Colors.blue),
      //         margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.32),
      //         child: Center(
      //           child: Container(
      //             width: width * 0.85,
      //             child: Column(
      //               children: [
      //                 Icon(Icons.keyboard_arrow_down, size: 30, color: Theme.of(context).primaryColor,),
      //                 Text(
      //                   data.title!,
      //                   textAlign: TextAlign.center,
      //                   style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.w500),
      //                   // style: Theme.of(context).textTheme.hev adline6,
      //                 ),
      //                 Padding(padding: EdgeInsets.only(top: 10.0),),
      //                 data.location != null && data.location!.isNotEmpty
      //                     ? LinkifyWithCatch(
      //                   text: "Where: " + data.location!,
      //                   looseUrl: true,
      //                   style: TextStyle(fontSize: 16, height: 1.3, color: Theme.of(context).primaryColor),
      //                   textAlign: TextAlign.center,
      //                 )
      //                     : Container(),
      //                 Padding(padding: EdgeInsets.only(top: 10.0),),
      //                 Center(child: EventTime(data: data)),
      //                 data.description != null && data.description!.isNotEmpty
      //                     ? Padding(
      //                   padding: const EdgeInsets.all(20.0),
      //                   child: Text(
      //                      data.description!,
      //                     style: TextStyle(fontSize: 16, height: 1.3),
      //                   ),
      //                 )
      //                     : Container(),
      //                 data.link != null && data.link!.isNotEmpty
      //                     ? LearnMoreButton(link: data.link)
      //                     : Container(),
      //               ],
      //             ),
      //           )),
      //       ),
      //
      //     ],
      //   ),
      // ),

      // Container(
      //   width: width,
      //   height: height / 6,
      //   color: Colors.blue,
      //   child: Image.network(data.imageHQ!),
      // ),

      //Image.network(data.imageHQ!, width: width * 2, height: height / 3.0,),
        // child: ImageLoader(
        //   url: data.imageHQ,
        //   width: width,
        //   height: height / 3.0,
        //   fullSize: false,
        // ),
     // Padding(padding: EdgeInsets.only(top: 100.0),),

      // Divider(),


  }
}

class LearnMoreButton extends StatelessWidget {
  const LearnMoreButton({Key? key, required this.link}) : super(key: key);
  final String? link;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            onPrimary: Theme.of(context).primaryColor, // foreground
            primary: Theme.of(context).buttonColor,
          ),
          child: Text(
            'Learn More',
            style: TextStyle(
                fontSize: 16, color: Theme.of(context).textTheme.button!.color),
          ),
          onPressed: () async {
            try {
              await launch(link!, forceSafariVC: true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Could not open.'),
              ));
            }
          }),
    );
  }
}
