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
fun SettingsScreen(onBack: () -> Unit) {
    var darkMode by remember { mutableStateOf(false) }

    Scaffold(
        topBar = { TopAppBar(title = { Text("Pengaturan", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Card(shape = RoundedCornerShape(16.dp)) {
                Column(Modifier.padding(horizontal = 16.dp)) {
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.DarkMode, contentDescription = null, tint = Grey600)
                        Spacer(Modifier.width(16.dp))
                        Text("Mode Gelap", modifier = Modifier.weight(1f))
                        Switch(checked = darkMode, onCheckedChange = { darkMode = it })
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Notifications, contentDescription = null, tint = Grey600)
                        Spacer(Modifier.width(16.dp))
                        Column(Modifier.weight(1f)) { Text("Notifikasi"); Text("Atur preferensi notifikasi", style = MaterialTheme.typography.bodySmall, color = Grey500) }
                        Icon(Icons.Default.ChevronRight, contentDescription = null, tint = Grey400)
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Lock, contentDescription = null, tint = Grey600)
                        Spacer(Modifier.width(16.dp))
                        Column(Modifier.weight(1f)) { Text("Keamanan"); Text("Password, biometric, 2FA", style = MaterialTheme.typography.bodySmall, color = Grey500) }
                        Icon(Icons.Default.ChevronRight, contentDescription = null, tint = Grey400)
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Language, contentDescription = null, tint = Grey600)
                        Spacer(Modifier.width(16.dp))
                        Text("Bahasa", modifier = Modifier.weight(1f))
                        Text("Indonesia", color = Grey500)
                    }
                    HorizontalDivider()
                    Row(Modifier.fillMaxWidth().padding(vertical = 14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Delete, contentDescription = null, tint = Red500)
                        Spacer(Modifier.width(16.dp))
                        Text("Hapus Akun", color = Red500)
                    }
                }
            }
        }
    }
}
