package com.clay.feature.chat

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatListScreen(
    onBack: () -> Unit,
    onConversationClick: (String) -> Unit,
) {
    val conversations = listOf(
        listOf("C001", "Budi Santoso", "Baik kak, saya sudah di lokasi", "14:35", "0"),
        listOf("C002", "Clay Support", "Silakan jelaskan kendala Anda", "13:00", "1"),
        listOf("C003", "Kurir ClaySend", "Paket sudah sampai tujuan", "10:30", "0"),
        listOf("C004", "Dokter Tania", "Jangan lupa minum obat", "15:00", "2"),
        listOf("C005", "PetShop Happy", "Anjing sudah selesai grooming", "11:30", "0"),
    )

    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        TopAppBar(
            title = { Text("Pesan", fontWeight = FontWeight.Bold) },
            colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.background),
        )

        Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(horizontal = 16.dp)) {
            conversations.forEach { conv ->
                Row(
                    modifier = Modifier.fillMaxWidth().clickable { onConversationClick(conv[0] as String) }.padding(vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Box(modifier = Modifier.size(52.dp).clip(CircleShape).background(ClayPrimary), contentAlignment = Alignment.Center) {
                        Text((conv[1] as String).take(2), color = MaterialTheme.colorScheme.onPrimary, fontWeight = FontWeight.Bold)
                    }
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                            Text(conv[1] as String, fontWeight = FontWeight.Medium)
                            Text(conv[3] as String, style = MaterialTheme.typography.bodySmall, color = Grey400)
                        }
                        Spacer(Modifier.height(4.dp))
                        Row(Modifier.fillMaxWidth()) {
                            Text(conv[2] as String, style = MaterialTheme.typography.bodyMedium, color = Grey500, maxLines = 1, overflow = TextOverflow.Ellipsis, modifier = Modifier.weight(1f))
                            if ((conv[4] as String).toInt() > 0) {
                                Badge { Text(conv[4] as String) }
                            }
                        }
                    }
                }
            }
        }
    }
}
