package com.clay.feature.activity

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsCar
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
fun ActivityScreen(
    onBack: () -> Unit,
    onOrderClick: (String) -> Unit,
) {
    var selectedFilter by remember { mutableIntStateOf(0) }
    val filters = listOf("Semua", "ClayRide", "ClayFood", "ClaySend", "ClayPet", "ClayWaste", "ClayCare")

    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        TopAppBar(
            title = { Text("Aktivitas", fontWeight = FontWeight.Bold) },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.background),
        )

        Row(
            modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()).padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
        ) {
            filters.forEachIndexed { index, filter ->
                FilterChip(
                    selected = selectedFilter == index,
                    onClick = { selectedFilter = index },
                    label = { Text(filter) },
                )
            }
        }

        Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(16.dp)) {
            listOf(
                listOf("ClayRide", "Ke Mall Kelapa Gading", "Rp25.000", "19 Mei 2025", "Selesai"),
                listOf("ClayFood", "Warung Nusantara", "Rp45.000", "19 Mei 2025", "Selesai"),
                listOf("ClayRide", "Ke Senayan City", "Rp35.000", "18 Mei 2025", "Selesai"),
                listOf("ClaySend", "Paket ke Kantor", "Rp15.000", "17 Mei 2025", "Selesai"),
                listOf("ClayRide", "Ke Rumah", "Rp30.000", "16 Mei 2025", "Selesai"),
                listOf("ClayPet", "Grooming Milo", "Rp75.000", "15 Mei 2025", "Selesai"),
                listOf("ClayCare", "Konsultasi Dokter", "Rp150.000", "14 Mei 2025", "Selesai"),
            ).forEach { item ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    onClick = { onOrderClick(item[0]) },
                ) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier.size(44.dp).background(
                                when (item[0]) {
                                    "ClayRide" -> Blue50
                                    "ClayFood" -> Orange50
                                    "ClaySend" -> Green50
                                    "ClayPet" -> Blue50
                                    "ClayWaste" -> Orange50
                                    "ClayCare" -> Green50
                                    else -> Grey100
                                }, RoundedCornerShape(12.dp),
                            ),
                            contentAlignment = Alignment.Center,
                        ) {
                            Icon(
                                when (item[0]) {
                                    "ClayRide" -> Icons.AutoMirrored.Filled.DirectionsCar
                                    "ClayFood" -> Icons.Default.Restaurant
                                    "ClaySend" -> Icons.Default.LocalShipping
                                    "ClayPet" -> Icons.Default.Pets
                                    "ClayWaste" -> Icons.Default.Delete
                                    "ClayCare" -> Icons.Default.LocalHospital
                                    else -> Icons.Default.Receipt
                                }, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(24.dp),
                            )
                        }
                        Spacer(Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(item[0] as String, fontWeight = FontWeight.Medium)
                            Text(item[1] as String, style = MaterialTheme.typography.bodySmall, color = Grey500)
                            Text(item[3] as String, style = MaterialTheme.typography.bodySmall, color = Grey400)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text(item[2] as String, fontWeight = FontWeight.Bold, color = ClayPrimary)
                            Text(item[4] as String, style = MaterialTheme.typography.labelSmall, color = Green500)
                        }
                    }
                }
            }
        }
    }
}
