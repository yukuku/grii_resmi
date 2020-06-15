package com.thnkld.kidung.app

import android.util.LruCache

object RenderedImageCache {
    private val cache = object : LruCache<String, ByteArray>(4000000) {
        override fun sizeOf(key: String?, value: ByteArray?): Int {
            return value?.size ?: 0
        }
    }

    fun put(key: String, value: ByteArray) {
        cache.put(key, value)
    }

    fun has(key: String): Boolean {
        return cache[key] != null
    }

    fun get(key: String): ByteArray {
        return cache[key]!!
    }
}
