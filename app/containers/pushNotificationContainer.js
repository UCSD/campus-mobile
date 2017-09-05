import React from 'react';
import {
  Alert,
  Platform,
} from 'react-native';

import { connect } from 'react-redux';
import FCM, {
  FCMEvent,
} from 'react-native-fcm';
import Permissions from 'react-native-permissions';

class PushNotificationContainer extends React.Component {
  componentDidMount() {
    this.checkPermission();

    // if we launch with a notification waiting for us
    // Note: Have to check what type of notification it is, especially on android, since some non-push things are notifications
    FCM.getInitialNotification().then((notif) => {
      console.log('launched w/notification waiting for us', notif);
    });

    this.notificationListener = FCM.on(FCMEvent.Notification, (notif) => {
      if (!notif) return; // make sure we get something

      console.log('got notification', notif);

      // there are two parts of notif. notif.notification contains the notification payload, notif.data contains data payload
      if (notif.local_notification) {
        // this is a local notification
        return;
      }
      if (notif.opened_from_tray) {
        // app is open/resumed because user clicked banner
        return;
      }

      // if app is already open, show a local notification with the same info
      this.showLocalNotification(notif);
    });
    this.refreshTokenListener = FCM.on(FCMEvent.RefreshToken, (token) => {
      this.updateServerToken(token);
      // fcm token may not be available on first load, catch it here
    });
  }

  componentWillUnmount() {
    // stop listening for events
    this.notificationListener.remove();
    this.refreshTokenListener.remove();
  }

  getNotificationToken = () => {
    FCM.getFCMToken().then((token) => {
      this.updateServerToken(token);
    });
  }

  getSoftPermission = () => {
    Alert.alert(
      'Allow this app to send you notifications?',
      'We need access so we can keep you informed.',
      [
        { text: 'No', onPress: () => {} },
        { text: 'Yes', onPress: this.getPermission }
      ]
    );
  }

  getPermission = () => {
    Permissions.requestPermission('notification')
    .then((response) => {
      // if authorized, act
      if (response === 'authorized') {
        this.getNotificationToken();
      }
    })
  }

  showLocalNotification = (notif) => {
    // NOTE: will not work until we configure local notifications
    if (notif && notif.notification) {
      FCM.presentLocalNotification({
        title: notif.notification.title,
        body: notif.notification.body,
        priority: 'high',
        click_action: notif.notification.click_action,
        show_in_foreground: true,
        local: true
      });
    }
  }

  checkPermission = () => {
    if (Platform.OS === 'ios') {
      // check for permission and either ask for it
      // or if we already have it then update the device tokens
      Permissions.getPermissionStatus('notification')
      .then((response) => {
        if (response === 'undetermined') {
          this.getPermission();
        } else if (response === 'authorized') {
          this.getNotificationToken();
        }
      });
    } else {
      // android always has permissions, just go get the notification token
      this.getNotificationToken();
    }
  }

  // Set device information along with app push ID token
  updateServerToken = (token) => {
    console.log('push token', token);

    // TODO: send token to server so we can push notifications here
  }

  render() {
    return null; // TODO: render error message if user does not allow location
  }
}

function mapStateToProps(state, props) {
  return {
  };
}

module.exports = connect(mapStateToProps)(PushNotificationContainer);
