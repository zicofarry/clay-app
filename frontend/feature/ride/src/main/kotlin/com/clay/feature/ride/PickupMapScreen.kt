package com.clay.feature.ride

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
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
fun PickupMapScreen(
    onBack: () -> Unit,
    onConfirm: () -> Unit,
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Konfirmasi Lokasi") },
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
                    Card(shape = RoundedCornerShape(12.dp)) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Circle, contentDescription = null, tint = Green500, modifier = Modifier.size(12.dp))
                                Spacer(Modifier.width(8.dp))
                                Text("Jl. Merdeka No. 10, Jakarta Pusat")
                            }
                            Spacer(Modifier.height(8.dp))
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(12.dp))
                                Spacer(Modifier.width(8.dp))
                                Text("Mall Kelapa Gading, Jakarta Utara")
                            }
                        }
                    }
                    Spacer(Modifier.height(12.dp))
                    Button(
                        onClick = onConfirm,
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Text("Konfirmasi", fontWeight = FontWeight.Bold)
                    }
                }
            }
        },
    ) { padding ->
        Box(
            modifier = Modifier.fillMaxSize().padding(padding).background(Grey200),
            contentAlignment = Alignment.Center,
        ) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(Icons.Default.Map, contentDescription = null, modifier = Modifier.size(64.dp), tint = Grey400)
                Spacer(Modifier.height(8.dp))
                Text("Map View", color = Grey500)
                Text("(Integrasi Google Maps / OpenStreetMap)", color = Grey400, style = MaterialTheme.typography.bodySmall)
            }

            Icon(
                Icons.Default.LocationOn,
                contentDescription = null,
                tint = ClayPrimary,
                modifier = Modifier.size(48.dp).align(Alignment.Center),
            )
        }
    }
}
