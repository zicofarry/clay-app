package com.clay.feature.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatDetailScreen(onBack: () -> Unit) {
    var message by remember { mutableStateOf("") }
    val messages = listOf(
        false to "Halo kak, saya sudah di lokasi",
        true to "Baik pak, sebentar lagi keluar",
        false to "Baik kak, saya tunggu",
        false to "Saya parkir di depan gerbang",
        true to "Oke pak, sudah keluar",
        false to "Baik kak, saya sudah di lokasi",
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Column { Text("Budi Santoso", fontWeight = FontWeight.Bold); Text("Online", style = MaterialTheme.typography.bodySmall, color = Green500) } },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    OutlinedTextField(
                        value = message,
                        onValueChange = { message = it },
                        placeholder = { Text("Ketik pesan...") },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(24.dp),
                        singleLine = true,
                    )
                    Spacer(Modifier.width(8.dp))
                    FilledIconButton(onClick = { message = "" }) {
                        Icon(Icons.Default.Send, contentDescription = "Send")
                    }
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).background(Grey50),
            verticalArrangement = Arrangement.Bottom,
        ) {
            messages.forEach { (isMine, text) ->
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 4.dp),
                    horizontalArrangement = if (isMine) Arrangement.End else Arrangement.Start,
                ) {
                    Card(
                        shape = RoundedCornerShape(
                            topStart = 16.dp, topEnd = 16.dp,
                            bottomStart = if (isMine) 16.dp else 4.dp,
                            bottomEnd = if (isMine) 4.dp else 16.dp,
                        ),
                        colors = CardDefaults.cardColors(
                            containerColor = if (isMine) ClayPrimary else MaterialTheme.colorScheme.surface,
                        ),
                    ) {
                        Text(
                            text,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp),
                            color = if (isMine) MaterialTheme.colorScheme.onPrimary else MaterialTheme.colorScheme.onSurface,
                        )
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
        }
    }
}
