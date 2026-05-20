package com.clay.feature.notifications

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotificationsScreen(onBack: () -> Unit) {
    var selectedFilter by remember { mutableIntStateOf(0) }

    val notifications = listOf(
        listOf("Promo PayDay!", "Dapatkan diskon 50% semua layanan Clay", "20 Mei 2025", "promo", "unread"),
        listOf("Pesanan Selesai", "Berikan rating untuk perjalanan Anda", "19 Mei 2025", "order", "unread"),
        listOf("Pembayaran Berhasil", "Top Up Rp500.000 berhasil", "19 Mei 2025", "payment", "read"),
        listOf("Promo ClayFood", "Gratis ongkir + diskon 25%", "18 Mei 2025", "promo", "read"),
        listOf("Peringatan Saldo", "Saldo Anda tinggal Rp25.000", "18 Mei 2025", "payment", "unread"),
        listOf("Pesanan Baru", "Pesanan ClayFood sedang diproses", "17 Mei 2025", "order", "read"),
        listOf("Promo Weekend", "ClayRide diskon 30%", "16 Mei 2025", "promo", "read"),
        listOf("Top Up Berhasil", "Top Up Rp200.000 berhasil", "15 Mei 2025", "payment", "read"),
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Notifikasi", fontWeight = FontWeight.Bold) },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } },
                actions = { TextButton(onClick = {}) { Text("Tandai Semua Dibaca", color = ClayPrimary) } },
            )
        },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background)) {
            Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("Semua", "Promo", "Pesanan", "Pembayaran").forEachIndexed { index, filter ->
                    FilterChip(selected = selectedFilter == index, onClick = { selectedFilter = index }, label = { Text(filter) })
                }
            }

            Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp)) {
                notifications.forEach { notif ->
                    Card(
                        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = if (notif[4] == "unread") Blue50 else MaterialTheme.colorScheme.surface,
                        ),
                    ) {
                        Row(modifier = Modifier.padding(16.dp)) {
                            Box(
                                Modifier.size(40.dp).background(
                                    when (notif[3]) {
                                        "promo" -> Orange50
                                        "order" -> Blue50
                                        "payment" -> Green50
                                        else -> Grey100
                                    }, RoundedCornerShape(12.dp),
                                ),
                                contentAlignment = Alignment.Center,
                            ) {
                                Icon(
                                    when (notif[3]) {
                                        "promo" -> Icons.Default.LocalOffer
                                        "order" -> Icons.Default.Receipt
                                        "payment" -> Icons.Default.Payment
                                        else -> Icons.Default.Notifications
                                    }, contentDescription = null,
                                    tint = when (notif[3]) {
                                        "promo" -> Orange500
                                        "order" -> ClayPrimary
                                        "payment" -> Green500
                                        else -> Grey500
                                    }, modifier = Modifier.size(20.dp),
                                )
                            }
                            Spacer(Modifier.width(12.dp))
                            Column(Modifier.weight(1f)) {
                                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                    Text(notif[0] as String, fontWeight = if (notif[4] == "unread") FontWeight.Bold else FontWeight.Medium)
                                    if (notif[4] == "unread") {
                                        Box(Modifier.size(8.dp).background(ClayPrimary, RoundedCornerShape(4.dp)))
                                    }
                                }
                                Spacer(Modifier.height(4.dp))
                                Text(notif[1] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                                Text(notif[2] as String, style = MaterialTheme.typography.bodySmall, color = Grey400)
                            }
                        }
                    }
                }
            }
        }
    }
}
