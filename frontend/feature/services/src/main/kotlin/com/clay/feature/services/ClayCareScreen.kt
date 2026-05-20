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
fun ClayCareScreen(onBack: () -> Unit) {
    Scaffold(
        topBar = { TopAppBar(title = { Text("ClayCare", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Text("Layanan kesehatan untukmu", style = MaterialTheme.typography.bodyMedium, color = Grey500)
            Spacer(Modifier.height(20.dp))
            listOf("Dokter Umum" to Icons.Default.Person, "Beli Obat" to Icons.Default.MedicalServices, "Laboratorium" to Icons.Default.Science, "Konsultasi Ibu & Anak" to Icons.Default.Favorite, "Kesehatan Mental" to Icons.Default.Psychology, "Fisioterapi" to Icons.Default.SelfImprovement).forEach { (name, icon) ->
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
            Text("Dokter Tersedia", fontWeight = FontWeight.SemiBold)
            Spacer(Modifier.height(12.dp))
            listOf("dr. Tania Wijaya, Sp.Um" to "Rs. Siloam • 4.9", "dr. Andi Pratama, Sp.Um" to "Rs. Mayapada • 4.8").forEach { (name, info) ->
                Card(modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp), shape = RoundedCornerShape(12.dp)) {
                    Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(48.dp).background(ClayPrimary, RoundedCornerShape(24.dp)), contentAlignment = Alignment.Center) { Text(name.take(2), color = MaterialTheme.colorScheme.onPrimary, fontWeight = FontWeight.Bold) }
                        Spacer(Modifier.width(12.dp))
                        Column(modifier = Modifier.weight(1f)) { Text(name, fontWeight = FontWeight.Medium); Text(info, style = MaterialTheme.typography.bodySmall, color = Grey500) }
                        Button(onClick = {}, shape = RoundedCornerShape(8.dp), contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)) { Text("Buat Janji", style = MaterialTheme.typography.labelSmall) }
                    }
                }
            }
        }
    }
}
