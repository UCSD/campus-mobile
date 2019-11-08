import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:campus_mobile_experimental/ui/views/special_events/banner_container.dart';
import 'package:campus_mobile_experimental/ui/widgets/image_loader.dart';
import 'package:flutter/material.dart';

class BannerCard extends StatefulWidget {
  @override
  _BannerCardState createState() => _BannerCardState();
}

class _BannerCardState extends State<BannerCard> {
  @override
  Widget build(BuildContext context) {
    return BannerContainer(
      isLoading: false,
      reload: () => print('reloading'),
      errorText: null,
      child: buildBannerView(),
      hidden: false,
    );
  }


  Widget buildBannerView() {
    return
    GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.SpecialEventsDetailView);
      },
    child: ImageLoader(
        url: 'https://s3-us-west-2.amazonaws.com/ucsd-its-wts/images/welcome-week/v1/WelcomeWeek.jpg',
        fullSize: true,
      )
    );
      
  }
}

  // void navigateToSpecialEvents() async {
  //   bool result = await Navigator.push(context, 
  //     MaterialPageRoute(builder: (context) => Text("DATA!!!!"))
  //     );
  // }
