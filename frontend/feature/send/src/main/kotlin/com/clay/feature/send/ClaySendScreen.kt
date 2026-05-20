package com.clay.feature.send

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
fun ClaySendScreen(onBack: () -> Unit) {
    var selectedType by remember { mutableIntStateOf(0) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("ClaySend", fontWeight = FontWeight.Bold) },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp),
        ) {
            Text("Kirim paket dengan mudah", style = MaterialTheme.typography.bodyMedium, color = Grey500)
            Spacer(Modifier.height(20.dp))

            listOf("Instan (1-3 jam)", "Same Day", "Reguler (1-2 hari)").forEachIndexed { index, type ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = if (selectedType == index) CardDefaults.cardColors(containerColor = Blue50) else CardDefaults.cardColors(),
                    onClick = { selectedType = index },
                ) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.LocalShipping, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(28.dp))
                        Spacer(Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(type, fontWeight = FontWeight.Medium)
                        }
                        RadioButton(selected = selectedType == index, onClick = { selectedType = index })
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            Card(shape = RoundedCornerShape(12.dp)) {
                Column(modifier = Modifier.padding(16.dp)) {
                    OutlinedTextField(value = "", onValueChange = {}, label = { Text("Lokasi Penjemputan") }, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), singleLine = true, leadingIcon = { Icon(Icons.Default.Circle, contentDescription = null, tint = Green500) })
                    Spacer(Modifier.height(12.dp))
                    OutlinedTextField(value = "", onValueChange = {}, label = { Text("Lokasi Tujuan") }, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), singleLine = true, leadingIcon = { Icon(Icons.Default.LocationOn, contentDescription = null, tint = ClayPrimary) })
                    Spacer(Modifier.height(12.dp))
                    OutlinedTextField(value = "", onValueChange = {}, label = { Text("Ukuran Paket") }, modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), singleLine = true, leadingIcon = { Icon(Icons.Default.Inventory2, contentDescription = null) })
                }
            }

            Spacer(Modifier.height(24.dp))
            Button(onClick = {}, modifier = Modifier.fillMaxWidth().height(52.dp), shape = RoundedCornerShape(12.dp)) {
                Text("Pesan ClaySend", fontWeight = FontWeight.Bold)
            }
        }
    }
}
