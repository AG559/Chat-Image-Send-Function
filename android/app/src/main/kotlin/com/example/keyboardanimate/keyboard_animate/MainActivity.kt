package com.example.keyboardanimate.keyboard_animate

import android.content.Intent
import kotlinx.coroutines.*
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "ag.test.thumbnail"
    private val imageExtensionList = listOf("jpeg", "jpg", "png", "gif")

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "listSyncFiles" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        filterCache(result)
                    }
                }
                "refreshGallery" -> {
                    val path = call.arguments
                    refreshGallery(path.toString());
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }


    private fun refreshGallery(path : String){
        val file = File(path)
        if(Build.VERSION.SDK_INT <29){
        context.sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(file)))
        }else{
            MediaScannerConnection.scanFile(context, arrayOf(file.toString()), arrayOf(file.name),null);
        }
        println("Successfully Refresh Gallery!")
    }

    private fun filterCache(result: MethodChannel.Result){
        val pref = context.getSharedPreferences("username", MODE_PRIVATE)
        val file = File("/storage/emulated/0")
        val prefImageList = pref.getStringSet("imageList", HashSet<String>())
        val jsonList = mutableListOf<JSONObject>()
        if (prefImageList != null && prefImageList.isNotEmpty()) {
            prefImageList.forEach {
                jsonList.add(JSONObject(it))
            }
        }
        val imageList = mutableListOf<String>()
        file.walk().filter { imageExtensionList.contains(it.extension) && !it.path.lowercase().contains("thumbnail") }.sortedByDescending { it.lastModified() }.forEach {
            val data: String
            val cacheData = jsonList.find { e -> e.getString("file") == it.path }
            data = cacheData?.toString() ?: getFileWithHeight(it.toString())
            imageList.add(data)
        }
        if (imageList.isNotEmpty()) {
            pref.edit().putStringSet("imageList", imageList.toHashSet()).apply()
        }
        result.success(imageList)
    }

    private fun getFileWithHeight(filePath: String): String {
        val options = BitmapFactory.Options()
        options.inJustDecodeBounds = true
        BitmapFactory.decodeFile(filePath, options)
        val width = options.outWidth
        val height = options.outHeight
        return """{"file":"$filePath","width":$width,"height":$height}"""
    }
  }
