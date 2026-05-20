package com.clay.feature.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.unit.sp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WalletScreen(
    onBack: () -> Unit,
    onTopUp: () -> Unit,
    onVoucher: () -> Unit,
) {
    val transactions = listOf(
        listOf("Top Up", "BCA", "+Rp500.000", "19 Mei 2025", "Berhasil"),
        listOf("ClayRide", "Budi Santoso", "-Rp35.000", "19 Mei 2025", "Berhasil"),
        listOf("ClayFood", "Warung Nusantara", "-Rp45.000", "19 Mei 2025", "Berhasil"),
        listOf("Top Up", "Mandiri", "+Rp200.000", "18 Mei 2025", "Berhasil"),
        listOf("Refund", "Promo ClayFood", "+Rp15.000", "17 Mei 2025", "Berhasil"),
        listOf("ClayRide", "Ahmad Rizki", "-Rp25.000", "16 Mei 2025", "Berhasil"),
    )

    Scaffold(
        topBar = { TopAppBar(title = { Text("Dompet", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState())) {
            Card(
                modifier = Modifier.fillMaxWidth().padding(16.dp),
                shape = RoundedCornerShape(20.dp),
                colors = CardDefaults.cardColors(containerColor = ClayWalletCardStart),
            ) {
                Column(Modifier.padding(20.dp)) {
                    Text("Saldo", color = MaterialTheme.colorScheme.onPrimary.copy(alpha = 0.8f))
                    Text("Rp2.500.000", color = MaterialTheme.colorScheme.onPrimary, fontSize = 32.sp, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.height(16.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        OutlinedButton(
                            onClick = onTopUp,
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.onPrimary),
                        ) { Icon(Icons.Default.Add, contentDescription = null); Spacer(Modifier.width(4.dp)); Text("Top Up") }
                        OutlinedButton(onClick = {}, modifier = Modifier.weight(1f), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.onPrimary)) { Icon(Icons.Default.SwapHoriz, contentDescription = null); Spacer(Modifier.width(4.dp)); Text("Transfer") }
                        OutlinedButton(onClick = {}, modifier = Modifier.weight(1f), shape = RoundedCornerShape(12.dp), colors = ButtonDefaults.outlinedButtonColors(contentColor = MaterialTheme.colorScheme.onPrimary)) { Icon(Icons.Default.QrCode, contentDescription = null); Spacer(Modifier.width(4.dp)); Text("QR Pay") }
                    }
                }
            }

            Column(Modifier.padding(horizontal = 16.dp)) {
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                    Text("Riwayat Transaksi", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
                    TextButton(onClick = onVoucher) { Text("Voucher") }
                }

                transactions.forEach { t ->
                    Row(Modifier.fillMaxWidth().padding(vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                        Box(Modifier.size(40.dp).background(if ((t[2] as String).startsWith("+")) Green50 else Orange50, RoundedCornerShape(12.dp)), contentAlignment = Alignment.Center) {
                            Icon(
                                when (t[0]) { "Top Up" -> Icons.Default.ArrowDownward; "Refund" -> Icons.Default.Refresh; else -> Icons.Default.ArrowUpward },
                                contentDescription = null,
                                tint = if ((t[2] as String).startsWith("+")) Green500 else Orange500,
                                modifier = Modifier.size(20.dp),
                            )
                        }
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(t[0] as String, fontWeight = FontWeight.Medium)
                            Text(t[1] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(t[2] as String, fontWeight = FontWeight.Bold, color = if ((t[2] as String).startsWith("+")) Green500 else ClayPrimary)
                            Text(t[3] as String, style = MaterialTheme.typography.bodySmall, color = Grey400)
                        }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}
