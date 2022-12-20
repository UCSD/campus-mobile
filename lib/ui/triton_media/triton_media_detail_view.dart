import 'package:campus_mobile_experimental/core/models/triton_media.dart';
import 'package:campus_mobile_experimental/core/providers/triton_media.dart';
import 'package:campus_mobile_experimental/ui/common/container_view.dart';
import 'package:campus_mobile_experimental/ui/common/media_time.dart';
import 'package:campus_mobile_experimental/ui/common/linkify_with_catch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';


class MediaDetailView extends StatefulWidget {
  const MediaDetailView({Key? key, required this.data}) : super(key: key);
  final MediaModel data;

  @override
  State<MediaDetailView> createState() => _MediaDetailView();
}

class _MediaDetailView extends State<MediaDetailView> {
  // _MediaDetailView({Key? key, required this.data});
  // final MediaModel data;

  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });

    player.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<MediaDataProvider>(context).isLoading!
        ? Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary))
        : ContainerView(
            child: buildDetailView(context),
          );
  }

  Widget buildDetailView(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Container(
          width: width,
          height: height * 0.33,
          decoration: BoxDecoration(
              image: DecorationImage(
            fit: BoxFit.fill,
            image: (widget.data.imageHQ!.isEmpty)
                ? AssetImage('assets/images/UCSDMobile_banner.png')
                    as ImageProvider
                : NetworkImage(widget.data.imageHQ!),
          )),
        ),
        Container(
          child: Center(
            child: Container(
              width: width * 0.8,
              child: Column(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    widget.data.title!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  widget.data.location != null && widget.data.location!.isNotEmpty
                      ? LinkifyWithCatch(
                          text: "Where: " + widget.data.location!,
                          looseUrl: true,
                          style: TextStyle(
                              fontSize: 16,
                              height: 1.3,
                              color: Theme.of(context).primaryColor),
                          textAlign: TextAlign.center,
                        )
                      : Container(),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),
                  Center(child: MediaTime(data: widget.data)),
                  widget.data.description != null && widget.data.description!.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            widget.data.description!,
                            style: TextStyle(fontSize: 16, height: 1.3),
                          ),
                        )
                      : Container(),
                  widget.data.link != null && widget.data.link!.isNotEmpty
                      ? LearnMoreButton(link: widget.data.link)
                      : Container(),

                ],
              ),
            ),
          ),
        ),
        Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      color: Colors.black,
                      icon:const Icon(Icons.replay_10_outlined),
                      onPressed: (){
                        player.stop();
                        },
                    ),
                    IconButton(
                      color: Colors.black,
                      iconSize: 50.0,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow
                      ),
                      onPressed: (){
                        if(isPlaying)
                        {
                          player.pause();
                        }
                        else{
                          player.play(AssetSource('theme_01.mp3'));
                        }
                        },
                    ),
                    IconButton(
                      color: Colors.black,
                      icon:const Icon(Icons.forward_10_outlined),
                      onPressed: (){
                        player.stop();},
                    ),
                  ],
                ),
                Slider(
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) {
                    final position = Duration(seconds: value.toInt());
                    player.seek(position);
                    player.resume();
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(position.inSeconds)),
                      Text(formatTime((duration - position).inSeconds)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
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
