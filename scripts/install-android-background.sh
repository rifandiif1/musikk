#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"
MAIN="android/app/src/main/java/com/richmusic/app/MainActivity.java"
PKGDIR="android/app/src/main/java/com/richmusic/app"
mkdir -p "$PKGDIR" android/app/src/main/res/drawable

cat > "$PKGDIR/BackgroundAudioPlugin.java" <<'JAVA'
package com.richmusic.app;

import android.content.Intent;
import android.os.Build;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "BackgroundAudio")
public class BackgroundAudioPlugin extends Plugin {
    @PluginMethod
    public void start(PluginCall call) {
        JSObject data = call.getData();
        String title = data.optString("title", "Rich Music");
        String artist = data.optString("artist", "Now playing");
        Intent intent = new Intent(getContext(), BackgroundAudioService.class);
        intent.setAction(BackgroundAudioService.ACTION_START);
        intent.putExtra("title", title);
        intent.putExtra("artist", artist);
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) getContext().startForegroundService(intent);
            else getContext().startService(intent);
            call.resolve();
        } catch (Exception ex) {
            call.reject("Unable to start background playback service", ex);
        }
    }

    @PluginMethod
    public void stop(PluginCall call) {
        try {
            getContext().stopService(new Intent(getContext(), BackgroundAudioService.class));
            call.resolve();
        } catch (Exception ex) {
            call.reject("Unable to stop background playback service", ex);
        }
    }
}
JAVA

cat > "$PKGDIR/BackgroundAudioService.java" <<'JAVA'
package com.richmusic.app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.IBinder;
import androidx.core.app.NotificationCompat;

public class BackgroundAudioService extends Service {
    public static final String ACTION_START = "com.richmusic.app.action.START_BACKGROUND_AUDIO";
    private static final String CHANNEL_ID = "rich_music_playback";
    private static final int NOTIFICATION_ID = 7401;

    @Override public void onCreate() {
        super.onCreate();
        NotificationManager manager = getSystemService(NotificationManager.class);
        if (manager != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Music playback", NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Shows when Rich Music playback is active");
            channel.setShowBadge(false);
            manager.createNotificationChannel(channel);
        }
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null || !ACTION_START.equals(intent.getAction())) { stopSelf(); return START_NOT_STICKY; }
        String title = intent.getStringExtra("title");
        String artist = intent.getStringExtra("artist");
        if (title == null || title.trim().isEmpty()) title = "Rich Music";
        if (artist == null || artist.trim().isEmpty()) artist = "Music is playing";
        Intent openApp = getPackageManager().getLaunchIntentForPackage(getPackageName());
        PendingIntent contentIntent = openApp == null ? null : PendingIntent.getActivity(this, 7402, openApp,
            PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= 23 ? PendingIntent.FLAG_IMMUTABLE : 0));
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_music)
            .setContentTitle(title)
            .setContentText(artist + " · Rich Music")
            .setSubText("Playback active")
            .setCategory(NotificationCompat.CATEGORY_TRANSPORT)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build();
        if (Build.VERSION.SDK_INT >= 29) startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK);
        else startForeground(NOTIFICATION_ID, notification);
        return START_NOT_STICKY;
    }

    @Override public void onDestroy() { stopForeground(true); super.onDestroy(); }
    @Override public IBinder onBind(Intent intent) { return null; }
}
JAVA

cat > android/app/src/main/res/drawable/ic_stat_music.xml <<'XML'
<vector xmlns:android="http://schemas.android.com/apk/res/android" android:width="24dp" android:height="24dp" android:viewportWidth="24" android:viewportHeight="24">
  <path android:fillColor="#FFFFFFFF" android:pathData="M12,3v11.2a3.5,3.5 0,1 0,2 3.2V7h6V3z" />
</vector>
XML

python3 - <<'PY'
from pathlib import Path
manifest=Path('android/app/src/main/AndroidManifest.xml')
s=manifest.read_text()
for permission in [
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />',
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />',
    '<uses-permission android:name="android.permission.WAKE_LOCK" />',
]:
    if permission not in s:
        s=s.replace('<application', permission+'\n    <application', 1)
service='''        <service
            android:name=".BackgroundAudioService"
            android:enabled="true"
            android:exported="false"
            android:foregroundServiceType="mediaPlayback"
            android:stopWithTask="false" />
'''
if '.BackgroundAudioService' not in s:
    s=s.replace('</application>', service+'    </application>')
manifest.write_text(s)
main=Path('android/app/src/main/java/com/richmusic/app/MainActivity.java')
s=main.read_text()
if 'BackgroundAudioPlugin.class' not in s:
    s=s.replace('public class MainActivity extends BridgeActivity {', 'public class MainActivity extends BridgeActivity {\n    @Override\n    public void onCreate(android.os.Bundle savedInstanceState) {\n        registerPlugin(BackgroundAudioPlugin.class);\n        super.onCreate(savedInstanceState);\n    }')
main.write_text(s)
PY
