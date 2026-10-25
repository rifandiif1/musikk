#!/usr/bin/env bash
set -euo pipefail

MANIFEST="android/app/src/main/AndroidManifest.xml"
MAIN="android/app/src/main/java/com/richmusic/app/MainActivity.java"
PKGDIR="android/app/src/main/java/com/richmusic/app"
mkdir -p "$PKGDIR" android/app/src/main/res/drawable

cat > "$PKGDIR/BackgroundAudioPlugin.java" <<'JAVA'
package com.richmusic.app;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.ActivityCallback;
import com.getcapacitor.annotation.CapacitorPlugin;
import androidx.activity.result.ActivityResult;

@CapacitorPlugin(name = "BackgroundAudio")
public class BackgroundAudioPlugin extends Plugin {
    @PluginMethod
    public void pickAudio(PluginCall call) {
        Intent intent = new Intent(Intent.ACTION_OPEN_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType("audio/*");
        intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION);
        startActivityForResult(call, intent, "audioPicked");
    }

    @ActivityCallback
    private void audioPicked(PluginCall call, ActivityResult result) {
        if (call == null) return;
        if (result.getResultCode() != android.app.Activity.RESULT_OK || result.getData() == null || result.getData().getData() == null) {
            call.reject("Pemilihan file dibatalkan"); return;
        }
        Uri uri = result.getData().getData();
        try { getContext().getContentResolver().takePersistableUriPermission(uri, Intent.FLAG_GRANT_READ_URI_PERMISSION); }
        catch (Exception ignored) { }
        JSObject data = new JSObject();
        data.put("uri", uri.toString());
        data.put("name", queryDisplayName(uri));
        call.resolve(data);
    }

    private String queryDisplayName(Uri uri) {
        try (android.database.Cursor c = getContext().getContentResolver().query(uri, new String[]{android.provider.OpenableColumns.DISPLAY_NAME}, null, null, null)) {
            if (c != null && c.moveToFirst()) return c.getString(0);
        } catch (Exception ignored) { }
        return "Audio lokal";
    }

    @PluginMethod
    public void playLocal(PluginCall call) {
        JSObject data = call.getData();
        String uri = data.optString("uri", "");
        String title = data.optString("title", "Audio lokal");
        String artist = data.optString("artist", "Perangkat ini");
        if (uri.isEmpty()) { call.reject("URI audio kosong"); return; }
        Intent intent = new Intent(getContext(), BackgroundAudioService.class);
        intent.setAction(BackgroundAudioService.ACTION_PLAY_LOCAL);
        intent.putExtra("uri", uri); intent.putExtra("title", title); intent.putExtra("artist", artist);
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) getContext().startForegroundService(intent);
            else getContext().startService(intent);
            call.resolve();
        } catch (Exception ex) { call.reject("Gagal memulai pemutar audio native", ex); }
    }

    private void send(String action) {
        Intent intent = new Intent(getContext(), BackgroundAudioService.class); intent.setAction(action);
        try { getContext().startService(intent); } catch (Exception ignored) { }
    }
    @PluginMethod public void pauseLocal(PluginCall call) { send(BackgroundAudioService.ACTION_PAUSE); call.resolve(); }
    @PluginMethod public void resumeLocal(PluginCall call) { send(BackgroundAudioService.ACTION_RESUME); call.resolve(); }
    @PluginMethod public void stopLocal(PluginCall call) { send(BackgroundAudioService.ACTION_STOP); call.resolve(); }
    @PluginMethod public void seekLocal(PluginCall call) {
        long position = call.getData().optLong("position", 0L);
        Intent intent = new Intent(getContext(), BackgroundAudioService.class);
        intent.setAction(BackgroundAudioService.ACTION_SEEK);
        intent.putExtra("position", Math.max(0L, position));
        try { getContext().startService(intent); call.resolve(); }
        catch (Exception ex) { call.reject("Tidak dapat mengubah posisi audio", ex); }
    }
    @PluginMethod public void getState(PluginCall call) {
        JSObject data = new JSObject();
        data.put("title", BackgroundAudioService.currentTitle);
        data.put("artist", BackgroundAudioService.currentArtist);
        data.put("playing", BackgroundAudioService.isPlaying);
        data.put("position", BackgroundAudioService.positionMs);
        data.put("duration", BackgroundAudioService.durationMs);
        data.put("active", BackgroundAudioService.isActive);
        call.resolve(data);
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
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaMetadata;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.SystemClock;
import androidx.core.app.NotificationCompat;

public class BackgroundAudioService extends Service {
    public static final String ACTION_PLAY_LOCAL = "com.richmusic.app.action.PLAY_LOCAL";
    public static final String ACTION_PAUSE = "com.richmusic.app.action.PAUSE";
    public static final String ACTION_RESUME = "com.richmusic.app.action.RESUME";
    public static final String ACTION_STOP = "com.richmusic.app.action.STOP";
    public static final String ACTION_SEEK = "com.richmusic.app.action.SEEK";
    private static final String CHANNEL_ID = "rich_music_playback";
    private static final int NOTIFICATION_ID = 7401;
    public static volatile String currentTitle = "Rich Music", currentArtist = "Audio lokal";
    public static volatile boolean isPlaying = false, isActive = false;
    public static volatile long positionMs = 0, durationMs = 0;
    private MediaPlayer player;
    private MediaSession session;
    private AudioManager audioManager;
    private AudioFocusRequest focusRequest;
    private boolean resumeAfterFocus = false;
    private final AudioManager.OnAudioFocusChangeListener focusListener = change -> {
        if (change == AudioManager.AUDIOFOCUS_LOSS) { resumeAfterFocus = false; pausePlayback(); }
        else if (change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT) { resumeAfterFocus = isPlaying; pausePlayback(); }
        else if (change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK) { if (player != null && isPlaying) { try { player.setVolume(0.25f, 0.25f); } catch (Exception ignored) {} } }
        else if (change == AudioManager.AUDIOFOCUS_GAIN) { if (player != null) { try { player.setVolume(1f, 1f); } catch (Exception ignored) {} } if (resumeAfterFocus) { resumeAfterFocus = false; resumePlayback(); } }
    };
    private final Handler handler = new Handler(Looper.getMainLooper());
    private final Runnable progress = new Runnable() { @Override public void run() {
        if (player != null && player.isPlaying()) { try { positionMs = player.getCurrentPosition(); } catch (Exception ignored) {} updateSessionState(); handler.postDelayed(this, 1000); }
    }};

    @Override public void onCreate() {
        super.onCreate();
        audioManager = (AudioManager) getSystemService(AUDIO_SERVICE);
        NotificationManager manager = getSystemService(NotificationManager.class);
        if (manager != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, "Music playback", NotificationManager.IMPORTANCE_LOW);
            channel.setDescription("Kontrol pemutaran audio lokal Rich Music"); channel.setShowBadge(false); manager.createNotificationChannel(channel);
        }
        session = new MediaSession(this, "RichMusicSession");
        session.setCallback(new MediaSession.Callback() {
            @Override public void onPlay() { resumePlayback(); }
            @Override public void onPause() { pausePlayback(); }
            @Override public void onStop() { stopPlayback(true); }
            @Override public void onSeekTo(long pos) { if (player != null) { try { player.seekTo((int)pos); positionMs = pos; updateSessionState(); } catch (Exception ignored) {} } }
        });
        session.setFlags(MediaSession.FLAG_HANDLES_MEDIA_BUTTONS | MediaSession.FLAG_HANDLES_TRANSPORT_CONTROLS);
        session.setActive(true);
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent == null || intent.getAction() == null) return START_NOT_STICKY;
        String action = intent.getAction();
        if (ACTION_PLAY_LOCAL.equals(action)) startLocal(intent);
        else if (ACTION_PAUSE.equals(action)) pausePlayback();
        else if (ACTION_RESUME.equals(action)) resumePlayback();
        else if (ACTION_STOP.equals(action)) stopPlayback(true);
        else if (ACTION_SEEK.equals(action) && player != null) { long position = Math.max(0L, intent.getLongExtra("position", 0L)); try { player.seekTo((int)Math.min(position, durationMs)); positionMs = Math.min(position, durationMs); updateSessionState(); } catch (Exception ignored) {} }
        return START_NOT_STICKY;
    }

    private void startLocal(Intent intent) {
        String uri = intent.getStringExtra("uri");
        if (uri == null || uri.isEmpty()) { stopSelf(); return; }
        currentTitle = value(intent.getStringExtra("title"), "Audio lokal");
        currentArtist = value(intent.getStringExtra("artist"), "Perangkat ini");
        stopPlayerOnly();
        try {
            if (!requestAudioFocus()) { isActive = false; stopSelf(); return; }
            player = new MediaPlayer();
            player.setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build());
            player.setWakeMode(getApplicationContext(), android.os.PowerManager.PARTIAL_WAKE_LOCK);
            player.setDataSource(getApplicationContext(), Uri.parse(uri));
            player.setOnPreparedListener(mp -> { durationMs = mp.getDuration(); positionMs = 0; mp.start(); isPlaying = true; isActive = true; updateMetadata(); updateSessionState(); showNotification(); handler.removeCallbacks(progress); handler.post(progress); });
            player.setOnCompletionListener(mp -> stopPlayback(true));
            player.setOnErrorListener((mp, what, extra) -> { stopPlayback(true); return true; });
            isActive = true; isPlaying = false;
            if (Build.VERSION.SDK_INT >= 29) startForeground(NOTIFICATION_ID, buildNotification(), android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK);
            else startForeground(NOTIFICATION_ID, buildNotification());
            player.prepareAsync();
        } catch (Exception e) { stopPlayback(true); }
    }
    private boolean requestAudioFocus() {
        if (audioManager == null) return true;
        int result;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            if (focusRequest == null) focusRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                .setAudioAttributes(new AudioAttributes.Builder().setUsage(AudioAttributes.USAGE_MEDIA).setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                .setOnAudioFocusChangeListener(focusListener).setWillPauseWhenDucked(false).build();
            result = audioManager.requestAudioFocus(focusRequest);
        } else {
            result = audioManager.requestAudioFocus(focusListener, AudioManager.STREAM_MUSIC, AudioManager.AUDIOFOCUS_GAIN);
        }
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
    }
    private void abandonAudioFocus() {
        if (audioManager == null) return;
        try { if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && focusRequest != null) audioManager.abandonAudioFocusRequest(focusRequest); else audioManager.abandonAudioFocus(focusListener); } catch (Exception ignored) {}
    }
    private String value(String s, String fallback) { return s == null || s.trim().isEmpty() ? fallback : s; }
    private void pausePlayback() { if (player != null && player.isPlaying()) { player.pause(); isPlaying = false; try { positionMs = player.getCurrentPosition(); } catch (Exception ignored) {} updateSessionState(); showNotification(); } }
    private void resumePlayback() { if (player != null) { try { if (!player.isPlaying()) { player.start(); isPlaying = true; updateSessionState(); showNotification(); handler.removeCallbacks(progress); handler.post(progress); } } catch (Exception ignored) {} } }
    private void stopPlayerOnly() { handler.removeCallbacks(progress); if (player != null) { try { player.setOnPreparedListener(null); player.stop(); } catch (Exception ignored) {} try { player.release(); } catch (Exception ignored) {} player = null; } }
    private void stopPlayback(boolean stopService) { stopPlayerOnly(); abandonAudioFocus(); resumeAfterFocus = false; isPlaying = false; isActive = false; positionMs = 0; durationMs = 0; if (session != null) { updateSessionState(); session.setActive(false); } NotificationManager nm = getSystemService(NotificationManager.class); if (nm != null) nm.cancel(NOTIFICATION_ID); stopForeground(true); if (stopService) stopSelf(); }
    private void updateMetadata() { if (session == null) return; session.setMetadata(new MediaMetadata.Builder().putString(MediaMetadata.METADATA_KEY_TITLE, currentTitle).putString(MediaMetadata.METADATA_KEY_ARTIST, currentArtist).putLong(MediaMetadata.METADATA_KEY_DURATION, durationMs).build()); session.setActive(true); }
    private void updateSessionState() { if (session == null) return; long actions = PlaybackState.ACTION_PLAY | PlaybackState.ACTION_PAUSE | PlaybackState.ACTION_PLAY_PAUSE | PlaybackState.ACTION_STOP | PlaybackState.ACTION_SEEK_TO; PlaybackState state = new PlaybackState.Builder().setActions(actions).setState(isPlaying ? PlaybackState.STATE_PLAYING : (isActive ? PlaybackState.STATE_PAUSED : PlaybackState.STATE_STOPPED), positionMs, 1.0f, SystemClock.elapsedRealtime()).build(); session.setPlaybackState(state); }
    private Notification buildNotification() {
        Intent open = getPackageManager().getLaunchIntentForPackage(getPackageName());
        PendingIntent content = open == null ? null : PendingIntent.getActivity(this, 7402, open, PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= 23 ? PendingIntent.FLAG_IMMUTABLE : 0));
        Intent toggle = new Intent(this, BackgroundAudioService.class).setAction(isPlaying ? ACTION_PAUSE : ACTION_RESUME);
        PendingIntent togglePending = PendingIntent.getService(this, 7403, toggle, PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= 23 ? PendingIntent.FLAG_IMMUTABLE : 0));
        Intent stop = new Intent(this, BackgroundAudioService.class).setAction(ACTION_STOP);
        PendingIntent stopPending = PendingIntent.getService(this, 7404, stop, PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= 23 ? PendingIntent.FLAG_IMMUTABLE : 0));
        return new NotificationCompat.Builder(this, CHANNEL_ID).setSmallIcon(R.drawable.ic_stat_music).setContentTitle(currentTitle).setContentText(currentArtist + " · Rich Music").setCategory(NotificationCompat.CATEGORY_TRANSPORT).setVisibility(NotificationCompat.VISIBILITY_PUBLIC).setOngoing(isActive).setOnlyAlertOnce(true).setContentIntent(content).setPriority(NotificationCompat.PRIORITY_LOW)
          .addAction(android.R.drawable.ic_media_pause == 0 ? 0 : (isPlaying ? android.R.drawable.ic_media_pause : android.R.drawable.ic_media_play), isPlaying ? "Jeda" : "Lanjutkan", togglePending)
          .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Berhenti", stopPending).build();
    }
    private void showNotification() { NotificationManager nm = getSystemService(NotificationManager.class); if (nm != null && isActive) nm.notify(NOTIFICATION_ID, buildNotification()); }
    @Override public void onTaskRemoved(Intent rootIntent) { /* Native local playback intentionally continues after task swipe. */ super.onTaskRemoved(rootIntent); }
    @Override public void onDestroy() { stopPlayerOnly(); abandonAudioFocus(); if (session != null) { session.setActive(false); session.release(); session = null; } isPlaying = false; isActive = false; super.onDestroy(); }
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
    '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
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
    s=s.replace('public class MainActivity extends BridgeActivity {', 'public class MainActivity extends BridgeActivity {\n    @Override\n    public void onCreate(android.os.Bundle savedInstanceState) {\n        registerPlugin(BackgroundAudioPlugin.class);\n        super.onCreate(savedInstanceState);\n        if (android.os.Build.VERSION.SDK_INT >= 33 && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) {\n            requestPermissions(new String[]{android.Manifest.permission.POST_NOTIFICATIONS}, 7405);\n        }\n    }\n')
main.write_text(s)
PY
