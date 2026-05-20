package com.clay.feature.food

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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FoodDetailScreen(
    onBack: () -> Unit,
    onAddToCart: () -> Unit,
) {
    var quantity by remember { mutableIntStateOf(1) }
    var notes by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        IconButton(onClick = { if (quantity > 1) quantity-- }) {
                            Icon(Icons.Default.RemoveCircleOutline, contentDescription = null, tint = ClayPrimary)
                        }
                        Text("$quantity", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                        IconButton(onClick = { quantity++ }) {
                            Icon(Icons.Default.AddCircle, contentDescription = null, tint = ClayPrimary)
                        }
                    }
                    Spacer(Modifier.width(12.dp))
                    Button(
                        onClick = onAddToCart,
                        modifier = Modifier.weight(1f).height(48.dp),
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Text("+ Tambah ke Keranjang • Rp${45000 * quantity}", fontWeight = FontWeight.Bold)
                    }
                }
            }
        },
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding).verticalScroll(rememberScrollState()).background(MaterialTheme.colorScheme.background),
        ) {
            Box(
                modifier = Modifier.fillMaxWidth().height(240.dp).background(Grey200),
                contentAlignment = Alignment.Center,
            ) {
                Icon(Icons.Default.Image, contentDescription = null, modifier = Modifier.size(64.dp), tint = Grey400)
            }

            Column(modifier = Modifier.padding(16.dp)) {
                Text("Nasi Goreng Spesial", fontWeight = FontWeight.Bold, fontSize = 22.sp)
                Spacer(Modifier.height(4.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Star, contentDescription = null, tint = Orange500, modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(4.dp))
                    Text("4.8", fontWeight = FontWeight.Medium)
                    Spacer(Modifier.width(16.dp))
                    Text("Terjual 500+", color = Grey500)
                }
                Spacer(Modifier.height(8.dp))
                Text(
                    "Nasi goreng dengan topping ayam suwir, udang, telur ceplok, dilengkapi acar dan kerupuk. Pilihan tepat untuk santap siang!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Grey600,
                )

                Spacer(Modifier.height(16.dp))
                HorizontalDivider()
                Spacer(Modifier.height(16.dp))

                Text("Tambahan (opsional)", fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(8.dp))
                listOf("Telur Tambahan" to 5000, "Keju Mozarella" to 8000, "Extra Ayam" to 12000, "Kerupuk" to 2000).forEach { (name, price) ->
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Checkbox(checked = false, onCheckedChange = {})
                        Spacer(Modifier.width(8.dp))
                        Text(name, modifier = Modifier.weight(1f))
                        Text("+Rp$price", color = ClayPrimary, fontWeight = FontWeight.Medium)
                    }
                }

                Spacer(Modifier.height(16.dp))
                HorizontalDivider()
                Spacer(Modifier.height(16.dp))

                OutlinedTextField(
                    value = notes,
                    onValueChange = { notes = it },
                    label = { Text("Catatan") },
                    placeholder = { Text("Contoh: Tidak pakai MSG") },
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp),
                )
            }
        }
    }
}
