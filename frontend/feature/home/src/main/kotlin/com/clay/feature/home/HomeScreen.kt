package com.clay.feature.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsCar
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.components.*
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToSearch: () -> Unit,
    onNavigateToNotifications: () -> Unit,
    onNavigateToRide: () -> Unit,
    onNavigateToFood: () -> Unit,
    onNavigateToSend: () -> Unit,
    onNavigateToPet: () -> Unit,
    onNavigateToWaste: () -> Unit,
    onNavigateToCare: () -> Unit,
    onNavigateToOtherServices: () -> Unit,
    onNavigateToWallet: () -> Unit,
) {
    val scrollState = rememberScrollState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .verticalScroll(scrollState),
    ) {
        TopAppBar(
            title = {
                Column {
                    Text("Halo, Raffi!", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Text("Selamat datang", style = MaterialTheme.typography.bodySmall, color = Grey500)
                }
            },
            actions = {
                IconButton(onClick = onNavigateToNotifications) {
                    Icon(Icons.Default.Notifications, contentDescription = "Notifikasi")
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.background),
        )

        Column(modifier = Modifier.padding(horizontal = 16.dp)) {
            ClayWalletCard(
                balance = 2500000,
                points = 2500,
                memberTier = "Gold Member",
                modifier = Modifier.clickable(onClick = onNavigateToWallet),
            )

            Spacer(Modifier.height(24.dp))

            ClayServiceGrid(
                items = listOf(
                    ServiceGridItem("ride", "ClayRide", Icons.AutoMirrored.Filled.DirectionsCar, Blue50, ClayPrimary),
                    ServiceGridItem("food", "ClayFood", Icons.Default.Restaurant, Orange50, Orange500),
                    ServiceGridItem("send", "ClaySend", Icons.Default.LocalShipping, Green50, Green500),
                    ServiceGridItem("pet", "ClayPet", Icons.Default.Pets, Blue50, ClayPrimary),
                    ServiceGridItem("waste", "ClayWaste", Icons.Default.Delete, Orange50, Orange500),
                    ServiceGridItem("care", "ClayCare", Icons.Default.LocalHospital, Green50, Green500),
                    ServiceGridItem("other", "Lainnya", Icons.Default.MoreHoriz, Grey100, Grey600),
                ),
                columns = 4,
                onItemClick = { item ->
                    when (item.id) {
                        "ride" -> onNavigateToRide()
                        "food" -> onNavigateToFood()
                        "send" -> onNavigateToSend()
                        "pet" -> onNavigateToPet()
                        "waste" -> onNavigateToWaste()
                        "care" -> onNavigateToCare()
                        "other" -> onNavigateToOtherServices()
                    }
                },
            )

            Spacer(Modifier.height(24.dp))

            ClaySectionHeader(title = "Promo Spesial", actionText = "Lihat Semua")
            Spacer(Modifier.height(12.dp))

            ClayPromoCard(
                title = "PayDay Sale! 🎉",
                description = "Diskon 50% semua layanan Clay. Limited time offer!",
            )
            Spacer(Modifier.height(8.dp))
            ClayPromoCard(
                title = "ClayFood Festival 🍔",
                description = "Gratis ongkir + diskon 25% untuk pesanan pertama ClayFood!",
            )

            Spacer(Modifier.height(24.dp))

            ClaySectionHeader(title = "Aktivitas Terakhir")
            Spacer(Modifier.height(12.dp))

            ClayOrderCard(
                title = "ClayRide",
                subtitle = "Ke Mall Kelapa Gading • 19 Mei 2025",
                price = "Rp25.000",
                status = "Selesai",
            )
            Spacer(Modifier.height(8.dp))
            ClayOrderCard(
                title = "ClayFood",
                subtitle = "Warung Nusantara • 19 Mei 2025",
                price = "Rp45.000",
                status = "Selesai",
            )

            Spacer(Modifier.height(24.dp))
        }
    }
}
