package com.clay.feature.ride

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsCar
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
fun DestinationConfirmationScreen(
    onBack: () -> Unit,
    onBook: () -> Unit,
) {
    var selectedVehicle by remember { mutableIntStateOf(0) }

    val vehicles = listOf(
        Triple("ClayRide Ekonomi", "Rp25.000", "4 penumpang"),
        Triple("ClayRide+", "Rp45.000", "6 penumpang"),
        Triple("ClayLux", "Rp95.000", "4 penumpang mewah"),
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Pilih Kendaraan") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text("Estimasi sampai", style = MaterialTheme.typography.bodyMedium, color = Grey500)
                        Text("15 menit", fontWeight = FontWeight.Bold)
                    }
                    Spacer(Modifier.height(4.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text("Pembayaran", style = MaterialTheme.typography.bodyMedium, color = Grey500)
                        Text("ClayPay", fontWeight = FontWeight.Bold, color = ClayPrimary)
                    }
                    Spacer(Modifier.height(12.dp))
                    Button(
                        onClick = onBook,
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Text("Pesan ClayRide", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).padding(16.dp),
        ) {
            Card(shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Circle, contentDescription = null, tint = Green500, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Jl. Merdeka No. 10", fontWeight = FontWeight.Medium)
                    }
                    Spacer(Modifier.height(4.dp))
                    Box(modifier = Modifier.padding(start = 4.dp)) {
                        Column {
                            repeat(3) {
                                Box(modifier = Modifier.size(2.dp, 2.dp).background(Grey400))
                                Spacer(Modifier.height(3.dp))
                            }
                        }
                    }
                    Spacer(Modifier.height(4.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Mall Kelapa Gading", fontWeight = FontWeight.Medium)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            vehicles.forEachIndexed { index, (name, price, capacity) ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = if (selectedVehicle == index) CardDefaults.cardColors(containerColor = Blue50)
                    else CardDefaults.cardColors(),
                    onClick = { selectedVehicle = index },
                ) {
                    Row(
                        modifier = Modifier.padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(Icons.AutoMirrored.Filled.DirectionsCar, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(32.dp))
                        Spacer(Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(name, fontWeight = FontWeight.Medium)
                            Text(capacity, style = MaterialTheme.typography.bodySmall, color = Grey500)
                        }
                        Text(price, fontWeight = FontWeight.Bold, color = ClayPrimary, fontSize = 16.sp)
                    }
                }
            }
        }
    }
}
