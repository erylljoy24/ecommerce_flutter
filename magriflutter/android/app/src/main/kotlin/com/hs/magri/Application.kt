package com.hs.magri;

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
import io.flutter.plugins.GeneratedPluginRegistrant
// import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService
// import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService

class Application : FlutterApplication() {
//class Application : FlutterApplication(), PluginRegistrantCallback {

    override fun onCreate() {
        super.onCreate()
        // FlutterFirebaseMessagingService.setPluginRegistrant(this);
        //FlutterFirebaseMessagingBackgroundService.setPluginRegistrant(this);
    }

    // override fun registerWith(registry: PluginRegistry?) {
    //     //GeneratedPluginRegistrant.registerWith(registry);
    //     //io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
    // }
}