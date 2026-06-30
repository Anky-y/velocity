package com.example.velocity

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "velocity/media_store"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "saveFile" -> {

                    val path = call.argument<String>("path")
                    val type = call.argument<String>("type")

                    if (path == null || type == null) {
                        result.error(
                            "INVALID_ARGS",
                            "Path or type is null",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val resultMap = saveFile(path, type)
                        result.success(resultMap)
                    } catch (e: Exception) {
                        result.error(
                            "SAVE_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                "fileExists" -> {

                    val uriString = call.argument<String>("uri")

                    if (uriString == null) {
                        result.error(
                            "INVALID_ARGS",
                            "Uri is null",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        result.success(fileExists(uriString))
                    } catch (e: Exception) {
                        result.error(
                            "CHECK_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun saveFile(
        path: String,
        type: String
    ): HashMap<String, String> {

        val file = File(path)
        val resolver = applicationContext.contentResolver

        val (collection, relativePath) = when (type) {

            "image" -> Pair(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                Environment.DIRECTORY_PICTURES + "/Velocity"
            )

            "video" -> Pair(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                Environment.DIRECTORY_MOVIES + "/Velocity"
            )

            "audio" -> Pair(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                Environment.DIRECTORY_MUSIC + "/Velocity"
            )

            else -> Pair(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                Environment.DIRECTORY_DOWNLOADS + "/Velocity"
            )
        }

        val values = ContentValues().apply {

            put(
                MediaStore.MediaColumns.DISPLAY_NAME,
                file.name
            )

            val extension = file.extension.lowercase()

            val mimeType =
                MimeTypeMap.getSingleton()
                    .getMimeTypeFromExtension(extension)
                    ?: "*/*"

            put(
                MediaStore.MediaColumns.MIME_TYPE,
                mimeType
            )

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    relativePath
                )
            }
        }

        val uri = resolver.insert(
            collection,
            values
        ) ?: throw Exception("Couldn't create MediaStore entry")

        resolver.openOutputStream(uri).use { output ->
            file.inputStream().use { input ->
                input.copyTo(output!!)
            }
        }

        var finalName = file.name

        try {

            val projection = arrayOf(
                MediaStore.MediaColumns.DISPLAY_NAME
            )

            resolver.query(
                uri,
                projection,
                null,
                null,
                null
            )?.use { cursor ->

                if (cursor.moveToFirst()) {

                    val index = cursor.getColumnIndex(
                        MediaStore.MediaColumns.DISPLAY_NAME
                    )

                    if (index != -1) {
                        finalName = cursor.getString(index)
                    }
                }
            }

        } catch (_: Exception) {
            // Keep original filename if query fails.
        }

        val resultMap = HashMap<String, String>()
        resultMap["uri"] = uri.toString()
        resultMap["name"] = finalName

        return resultMap
    }

    private fun fileExists(uriString: String): Boolean {

        val uri = Uri.parse(uriString)

        return try {
            contentResolver.openInputStream(uri)?.use {
                true
            } ?: false
        } catch (_: Exception) {
            false
        }
    }
}