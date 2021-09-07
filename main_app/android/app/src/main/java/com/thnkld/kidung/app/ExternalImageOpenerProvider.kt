package com.thnkld.kidung.app

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.database.MatrixCursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.provider.OpenableColumns
import android.util.Log
import java.io.File
import java.io.FileOutputStream

class ExternalImageOpenerProvider : ContentProvider() {

    private lateinit var savedContext: Context

    override fun onCreate(): Boolean {
        this.savedContext = context!!
        return true
    }

    override fun getType(uri: Uri): String {
        return "image/png"
    }

    override fun query(uri: Uri, projection: Array<out String>?, selection: String?, selectionArgs: Array<out String>?, sortOrder: String?): Cursor {
        Log.d(TAG, "@@query $uri")

        val res = MatrixCursor(arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE))
        val key = uri.lastPathSegment ?: "emptyLastPathSegment"
        if (!RenderedImageCache.has(key)) {
            return res
        }
        val bytes = RenderedImageCache.get(key)
        res.addRow(arrayOf("$key.png", bytes.size))
        return res
    }

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor? {
        Log.d(TAG, "@@openFile $uri")

        val key = uri.lastPathSegment ?: "emptyLastPathSegment"
        if (!RenderedImageCache.has(key)) {
            return super.openFile(uri, mode)
        }

        val bytes = RenderedImageCache.get(key)
        val tmp = File(savedContext.cacheDir, key)
        val fos = FileOutputStream(tmp)
        fos.write(bytes)
        fos.close()

        return ParcelFileDescriptor.open(tmp, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun insert(uri: Uri, values: ContentValues?): Uri? {
        throw UnsupportedOperationException("Not implemented")
    }

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int {
        throw UnsupportedOperationException("Not implemented")
    }

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int {
        throw UnsupportedOperationException("Not implemented")
    }

    companion object {
        const val TAG = "ExternalImageOpener"
    }
}
