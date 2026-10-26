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

    @PluginMethod
    public void playUrl(PluginCall call) {
        JSObject data = call.getData();
        String uri = data.optString("url", "");
        String title = data.optString("title", "Audio online");
        String artist = data.optString("artist", "Rich Music");
        if (!(uri.startsWith("https://") || uri.startsWith("http://"))) {
            call.reject("URL harus berupa URL audio HTTP(S) langsung, bukan tautan halaman atau ID YouTube"); return;
        }
        Intent intent = new Intent(getContext(), BackgroundAudioService.class);
        intent.setAction(BackgroundAudioService.ACTION_PLAY_URL);
        intent.putExtra("uri", uri); intent.putExtra("title", title); intent.putExtra("artist", artist);
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) getContext().startForegroundService(intent);
            else getContext().startService(intent);
            call.resolve();
        } catch (Exception ex) { call.reject("Gagal memulai audio online native", ex); }
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

import android.content.Intent;
import android.net.Uri;
import android.os.IBinder;
import android.os.SystemClock;
import androidx.annotation.Nullable;
import androidx.media3.common.AudioAttributes;
import androidx.media3.common.C;
import androidx.media3.common.MediaItem;
import androidx.media3.common.MediaMetadata;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.session.MediaSession;
import androidx.media3.session.MediaSessionService;

/** Owns the actual audio player and MediaSession independently of the Capacitor Activity. */
public final class BackgroundAudioService extends MediaSessionService {
    public static final String ACTION_PLAY_LOCAL = "com.richmusic.app.action.PLAY_LOCAL";
    public static final String ACTION_PLAY_URL = "com.richmusic.app.action.PLAY_URL";
    public static final String ACTION_PAUSE = "com.richmusic.app.action.PAUSE";
    public static final String ACTION_RESUME = "com.richmusic.app.action.RESUME";
    public static final String ACTION_STOP = "com.richmusic.app.action.STOP";
    public static final String ACTION_SEEK = "com.richmusic.app.action.SEEK";

    public static volatile String currentTitle = "Rich Music";
    public static volatile String currentArtist = "Audio lokal";
    public static volatile boolean isPlaying = false;
    public static volatile boolean isActive = false;
    public static volatile long positionMs = 0L;
    public static volatile long durationMs = 0L;

    private ExoPlayer player;
    private MediaSession mediaSession;

    @Override public void onCreate() {
        super.onCreate();
        player = new ExoPlayer.Builder(this).build();
        player.setAudioAttributes(new AudioAttributes.Builder()
                .setUsage(C.USAGE_MEDIA)
                .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                .build(), true);
        player.addListener(new Player.Listener() {
            @Override public void onIsPlayingChanged(boolean playing) {
                isPlaying = playing;
                isActive = player != null && player.getMediaItemCount() > 0
                        && player.getPlaybackState() != Player.STATE_IDLE;
                updateSnapshot();
            }
            @Override public void onPlaybackStateChanged(int state) { updateSnapshot(); }
            @Override public void onMediaMetadataChanged(MediaMetadata metadata) {
                if (metadata.title != null) currentTitle = metadata.title.toString();
                if (metadata.artist != null) currentArtist = metadata.artist.toString();
                updateSnapshot();
            }
            @Override public void onPlayerError(PlaybackException error) {
                isPlaying = false;
                updateSnapshot();
            }
        });
        mediaSession = new MediaSession.Builder(this, player).build();
    }

    @Nullable @Override public MediaSession onGetSession(MediaSession.ControllerInfo controllerInfo) {
        return mediaSession;
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String action = intent.getAction();
            if (ACTION_PLAY_LOCAL.equals(action) || ACTION_PLAY_URL.equals(action)) {
                String uri = intent.getStringExtra("uri");
                String title = value(intent.getStringExtra("title"), "Audio");
                String artist = value(intent.getStringExtra("artist"), "Rich Music");
                if (uri != null && !uri.trim().isEmpty()) startItem(Uri.parse(uri), title, artist);
                else stopSelf(startId);
            } else if (ACTION_PAUSE.equals(action)) {
                if (player != null) player.pause();
            } else if (ACTION_RESUME.equals(action)) {
                if (player != null && player.getMediaItemCount() > 0) player.play();
            } else if (ACTION_STOP.equals(action)) {
                if (player != null) { player.stop(); player.clearMediaItems(); }
                isPlaying = false; isActive = false; positionMs = 0L; durationMs = 0L;
                stopSelf(startId);
            } else if (ACTION_SEEK.equals(action) && player != null) {
                player.seekTo(Math.max(0L, intent.getLongExtra("position", 0L)));
            }
        }
        // MediaSessionService owns foreground promotion and the platform media notification.
        return super.onStartCommand(intent, flags, startId);
    }

    private void startItem(Uri uri, String title, String artist) {
        currentTitle = title; currentArtist = artist;
        MediaMetadata metadata = new MediaMetadata.Builder().setTitle(title).setArtist(artist).build();
        MediaItem item = new MediaItem.Builder().setUri(uri).setMediaMetadata(metadata).build();
        player.setMediaItem(item);
        player.prepare();
        player.play();
        isActive = true;
        updateSnapshot();
    }

    private String value(String input, String fallback) {
        return input == null || input.trim().isEmpty() ? fallback : input.trim();
    }

    private void updateSnapshot() {
        if (player == null) return;
        isPlaying = player.isPlaying();
        isActive = player.getMediaItemCount() > 0 && player.getPlaybackState() != Player.STATE_IDLE;
        positionMs = Math.max(0L, player.getCurrentPosition());
        long duration = player.getDuration();
        durationMs = duration == C.TIME_UNSET ? 0L : Math.max(0L, duration);
    }

    @Override public void onDestroy() {
        isPlaying = false; isActive = false;
        if (mediaSession != null) { mediaSession.release(); mediaSession = null; }
        if (player != null) { player.release(); player = null; }
        super.onDestroy();
    }
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
            android:exported="true"
            android:foregroundServiceType="mediaPlayback"
            android:stopWithTask="false">
            <intent-filter>
                <action android:name="androidx.media3.session.MediaSessionService" />
            </intent-filter>
        </service>
'''
if '.BackgroundAudioService' not in s:
    s=s.replace('</application>', service+'    </application>')
manifest.write_text(s)
# Media3 owns the player/session and generates the Android media notification from actual playback state.
gradle=Path('android/app/build.gradle')
if gradle.exists():
    gs=gradle.read_text()
    deps = [
        "implementation 'androidx.media3:media3-exoplayer:1.8.0'",
        "implementation 'androidx.media3:media3-session:1.8.0'",
    ]
    missing=[d for d in deps if d not in gs]
    if missing:
        import re
        match=re.search(r'dependencies\s*\{', gs)
        if not match:
            raise SystemExit('Tidak menemukan blok dependencies di android/app/build.gradle')
        pos=match.end()
        gs=gs[:pos]+"\n    "+"\n    ".join(missing)+gs[pos:]
        gradle.write_text(gs)
else:
    raise SystemExit('android/app/build.gradle belum ada; jalankan setelah npx cap add android')

main=Path('android/app/src/main/java/com/richmusic/app/MainActivity.java')
s=main.read_text()
if 'BackgroundAudioPlugin.class' not in s:
    s=s.replace('public class MainActivity extends BridgeActivity {', 'public class MainActivity extends BridgeActivity {\n    @Override\n    public void onCreate(android.os.Bundle savedInstanceState) {\n        registerPlugin(BackgroundAudioPlugin.class);\n        super.onCreate(savedInstanceState);\n        if (android.os.Build.VERSION.SDK_INT >= 33 && checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) {\n            requestPermissions(new String[]{android.Manifest.permission.POST_NOTIFICATIONS}, 7405);\n        }\n    }\n')
main.write_text(s)
PY
