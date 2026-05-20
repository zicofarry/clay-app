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
fun ClayPetScreen(onBack: () -> Unit) {
    Scaffold(
        topBar = { TopAppBar(title = { Text("ClayPet", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Text("Layanan untuk hewan kesayanganmu", style = MaterialTheme.typography.bodyMedium, color = Grey500)
            Spacer(Modifier.height(20.dp))
            listOf("Grooming" to Icons.Default.Face, "Klinik Hewan" to Icons.Default.LocalHospital, "Pet Hotel" to Icons.Default.Hotel, "Pet Shop" to Icons.Default.Store).forEach { (name, icon) ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), shape = RoundedCornerShape(12.dp)) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(icon, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(28.dp))
                        Spacer(Modifier.width(12.dp))
                        Text(name, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
                        Icon(Icons.Default.ChevronRight, contentDescription = null, tint = Grey400)
                    }
                }
            }
            Spacer(Modifier.height(24.dp))
            Text("Hewan Peliharaanmu", fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(12.dp))
            Card(shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(containerColor = Blue50)) {
                Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Pets, contentDescription = null, tint = ClayPrimary, modifier = Modifier.size(32.dp))
                    Spacer(Modifier.width(12.dp))
                    Column { Text("Milo", fontWeight = FontWeight.Bold); Text("Kucing • 2 tahun", style = MaterialTheme.typography.bodySmall, color = Grey600) }
                }
            }
        }
    }
}
