package com.clay.feature.profile

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.components.*
import com.clay.core.ui.theme.*

@Composable
fun ProfileScreen(
    onNavigateToWallet: () -> Unit,
    onNavigateToVoucher: () -> Unit,
    onNavigateToSettings: () -> Unit,
    onNavigateToHelp: () -> Unit,
) {
    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState())) {
        TopAppBar(
            title = { Text("Akun", fontWeight = FontWeight.Bold) },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.background),
        )

        Column(Modifier.padding(horizontal = 16.dp)) {
            Card(shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
                Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    ClayAvatar(imageUrl = null, name = "Raffi Ahmad", size = 60)
                    Spacer(Modifier.width(16.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Raffi Ahmad", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        Text("08123456789", color = Grey500)
                        Text("Gold Member", color = ClayGold, fontWeight = FontWeight.Medium, style = MaterialTheme.typography.bodySmall)
                    }
                    Icon(Icons.Default.ArrowForwardIos, contentDescription = null, tint = Grey400, modifier = Modifier.size(16.dp))
                }
            }

            Spacer(Modifier.height(16.dp))

            Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                listOf(Triple("156", "Perjalanan", Icons.Default.DirectionsCar), Triple("4.9", "Rating", Icons.Default.Star), Triple("2.5K", "Poin", Icons.Default.MonetizationOn)).forEach { (value, label, icon) ->
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(icon, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(24.dp))
                        Spacer(Modifier.height(4.dp))
                        Text(value, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        Text(label, style = MaterialTheme.typography.labelSmall, color = Grey500)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            Card(shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                    ClayMenuItem(Icons.Default.AccountBalanceWallet, "Dompet", "Rp2.500.000", onClick = onNavigateToWallet)
                    HorizontalDivider()
                    ClayMenuItem(Icons.Default.CardGiftcard, "Voucher", "5 voucher tersedia", onClick = onNavigateToVoucher)
                    HorizontalDivider()
                    ClayMenuItem(Icons.Default.Notifications, "Notifikasi", null, onClick = {})
                    HorizontalDivider()
                    ClayMenuItem(Icons.Default.Star, "Rating Saya", null, onClick = {})
                }
            }

            Spacer(Modifier.height(16.dp))

            Card(shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(horizontal = 16.dp)) {
                    ClayMenuItem(Icons.Default.Settings, "Pengaturan", null, onClick = onNavigateToSettings)
                    HorizontalDivider()
                    ClayMenuItem(Icons.Default.HelpOutline, "Bantuan", null, onClick = onNavigateToHelp)
                    HorizontalDivider()
                    ClayMenuItem(Icons.Default.Info, "Tentang Aplikasi", "Versi 1.0.0", onClick = {})
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}
