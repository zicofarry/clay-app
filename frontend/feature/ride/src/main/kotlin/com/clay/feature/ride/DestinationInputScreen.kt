package com.clay.feature.ride

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
fun DestinationInputScreen(
    onBack: () -> Unit,
    onProceed: () -> Unit,
) {
    var pickup by remember { mutableStateOf("") }
    var destination by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("ClayRide", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Button(
                    onClick = onProceed,
                    modifier = Modifier.fillMaxWidth().padding(16.dp).height(52.dp),
                    shape = RoundedCornerShape(12.dp),
                    enabled = pickup.isNotBlank() && destination.isNotBlank(),
                ) {
                    Text("Cari Driver", fontWeight = FontWeight.Bold)
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).padding(16.dp),
        ) {
            OutlinedTextField(
                value = pickup,
                onValueChange = { pickup = it },
                label = { Text("Lokasi Penjemputan") },
                leadingIcon = { Icon(Icons.Default.Circle, contentDescription = null, tint = Green500, modifier = Modifier.size(12.dp)) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
            )

            Spacer(Modifier.height(12.dp))

            OutlinedTextField(
                value = destination,
                onValueChange = { destination = it },
                label = { Text("Tujuan") },
                leadingIcon = { Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
            )

            Spacer(Modifier.height(24.dp))

            Text("Favorit", fontWeight = FontWeight.SemiBold, style = MaterialTheme.typography.titleSmall)
            Spacer(Modifier.height(8.dp))

            listOf("Rumah" to "Jl. Merdeka No. 10", "Kantor" to "Jl. Sudirman Kav. 45").forEach { (label, address) ->
                Row(
                    modifier = Modifier.fillMaxWidth().clickable {}.padding(vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(
                        modifier = Modifier.size(40.dp).background(Blue50, RoundedCornerShape(12.dp)),
                        contentAlignment = Alignment.Center,
                    ) {
                        Icon(
                            if (label == "Rumah") Icons.Default.Home else Icons.Default.Business,
                            contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(20.dp),
                        )
                    }
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text(label, fontWeight = FontWeight.Medium)
                        Text(address, style = MaterialTheme.typography.bodySmall, color = Grey500)
                    }
                }
            }
        }
    }
}
