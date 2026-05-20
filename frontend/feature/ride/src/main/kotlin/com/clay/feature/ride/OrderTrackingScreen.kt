package com.clay.feature.ride

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.DirectionsCar
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OrderTrackingScreen(
    onBack: () -> Unit,
    onComplete: () -> Unit,
) {
    var eta by remember { mutableIntStateOf(5) }
    var isArrived by remember { mutableStateOf(false) }

    LaunchedEffect(eta) {
        if (eta > 0 && !isArrived) {
            kotlinx.coroutines.delay(30000)
            eta--
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Perjalanan") },
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
                    Button(
                        onClick = onComplete,
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = ClayPrimary),
                    ) {
                        Text("Selesai", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).padding(16.dp),
        ) {
            Card(
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier.fillMaxWidth(),
            ) {
                Row(modifier = Modifier.padding(16.dp)) {
                    Box(
                        modifier = Modifier.size(56.dp).clip(CircleShape).background(ClayPrimary),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text("BS", color = MaterialTheme.colorScheme.onPrimary, fontWeight = FontWeight.Bold, fontSize = 20.sp)
                    }
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Budi Santoso", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text("Toyota Avanza B 1234 CD", style = MaterialTheme.typography.bodySmall, color = Grey500)
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Star, contentDescription = null, tint = Orange500, modifier = Modifier.size(14.dp))
                            Spacer(Modifier.width(4.dp))
                            Text("4.9", style = MaterialTheme.typography.bodySmall, fontWeight = FontWeight.Medium)
                        }
                    }
                    IconButton(onClick = { /* call driver */ }) {
                        Icon(Icons.Default.Phone, contentDescription = "Call", tint = ClayPrimary)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            Card(shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Circle, contentDescription = null, tint = Green500, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Jl. Merdeka No. 10", fontWeight = FontWeight.Medium)
                    }
                    Spacer(Modifier.height(4.dp))
                    Box(modifier = Modifier.padding(start = 4.dp)) {
                        Column { repeat(3) { Box(modifier = Modifier.size(2.dp).background(Grey400)) } }
                    }
                    Spacer(Modifier.height(4.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Mall Kelapa Gading", fontWeight = FontWeight.Medium)
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Blue50),
                modifier = Modifier.fillMaxWidth(),
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Icon(Icons.Default.Timer, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(24.dp))
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("Estimasi tiba", style = MaterialTheme.typography.bodySmall, color = Grey600)
                        Text("$eta menit lagi", fontWeight = FontWeight.Bold, fontSize = 20.sp, color = ClayPrimary)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            Box(
                modifier = Modifier.fillMaxWidth().height(200.dp).clip(RoundedCornerShape(16.dp)).background(Grey200),
                contentAlignment = Alignment.Center,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Default.Map, contentDescription = null, modifier = Modifier.size(48.dp), tint = Grey400)
                    Spacer(Modifier.height(4.dp))
                    Text("Live Map Tracking", color = Grey500)
                    Text("(Integrasi Google Maps)", color = Grey400, style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}
