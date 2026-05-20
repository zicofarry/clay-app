package com.clay.feature.services

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
fun ClayWasteScreen(onBack: () -> Unit) {
    Scaffold(
        topBar = { TopAppBar(title = { Text("ClayWaste", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Text("Kelola sampah dengan bijak", style = MaterialTheme.typography.bodyMedium, color = Grey500)
            Spacer(Modifier.height(20.dp))
            listOf("Organik" to Green500, "Plastik" to Orange500, "Kertas" to Blue500, "Elektronik" to Red600, "Logam" to Grey600, "Kaca" to ClayPrimary).forEach { (name, color) ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), shape = RoundedCornerShape(12.dp)) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(12.dp).background(color, RoundedCornerShape(6.dp)))
                        Spacer(Modifier.width(12.dp))
                        Text(name, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
                        Checkbox(checked = false, onCheckedChange = {})
                    }
                }
            }
            Spacer(Modifier.height(24.dp))
            Button(onClick = {}, modifier = Modifier.fillMaxWidth().height(52.dp), shape = RoundedCornerShape(12.dp)) {
                Text("Jadwalkan Penjemputan", fontWeight = FontWeight.Bold)
            }
        }
    }
}
