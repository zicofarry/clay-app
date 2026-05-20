package com.clay.core.common

import java.text.NumberFormat
import java.util.Locale

fun Int.formatRupiah(): String {
    val format = NumberFormat.getCurrencyInstance(Locale("id", "ID"))
    return format.format(this)
}

fun Int.formatCompact(): String = when {
    this >= 1_000_000 -> "${this / 1_000_000}jt"
    this >= 1_000 -> "${this / 1_000}rb"
    else -> toString()
}

fun String.toInitials(): String = split(" ")
    .take(2)
    .mapNotNull { it.firstOrNull()?.uppercase() }
    .joinToString("")

fun String.obfuscatePhone(): String = if (length >= 8) {
    substring(0, 3) + "****" + substring(length - 3)
} else {
    this
}
