package com.clay.feature.profile

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
fun HelpScreen(onBack: () -> Unit) {
    var expandedFaq by remember { mutableIntStateOf(-1) }

    Scaffold(
        topBar = { TopAppBar(title = { Text("Bantuan", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Card(shape = RoundedCornerShape(16.dp)) {
                Column(Modifier.padding(horizontal = 16.dp)) {
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Chat, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(16.dp))
                        Column(Modifier.weight(1f)) { Text("Live Chat", fontWeight = FontWeight.Medium); Text("Chat dengan tim support", style = MaterialTheme.typography.bodySmall, color = Grey500) }
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Phone, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(16.dp))
                        Column(Modifier.weight(1f)) { Text("Telepon", fontWeight = FontWeight.Medium); Text("021-1234-5678", style = MaterialTheme.typography.bodySmall, color = Grey500) }
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Email, contentDescription = null, tint = ClayPrimary)
                        Spacer(Modifier.width(16.dp))
                        Column(Modifier.weight(1f)) { Text("Email", fontWeight = FontWeight.Medium); Text("support@clay.id", style = MaterialTheme.typography.bodySmall, color = Grey500) }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
            Text("Pertanyaan Umum", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(12.dp))

            listOf("Bagaimana cara memesan ClayRide?", "Bagaimana cara top up saldo?", "Bagaimana cara menggunakan voucher?", "Bagaimana cara membatalkan pesanan?").forEachIndexed { index, question ->
                Card(
                    modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
                    shape = RoundedCornerShape(12.dp),
                    onClick = { expandedFaq = if (expandedFaq == index) -1 else index },
                ) {
                    Column(Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(question, fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
                            Icon(if (expandedFaq == index) Icons.Default.ExpandLess else Icons.Default.ExpandMore, contentDescription = null, tint = Grey400)
                        }
                        if (expandedFaq == index) {
                            Spacer(Modifier.height(8.dp))
                            Text("Fitur ini akan segera hadir. Pantau terus update aplikasi Clay untuk informasi selengkapnya.", style = MaterialTheme.typography.bodySmall, color = Grey500)
                        }
                    }
                }
            }
        }
    }
}
