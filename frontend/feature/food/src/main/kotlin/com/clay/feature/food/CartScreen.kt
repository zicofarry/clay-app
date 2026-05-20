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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.clay.core.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CartScreen(
    onBack: () -> Unit,
    onCheckout: () -> Unit,
) {
    var quantities by remember { mutableStateOf(mapOf("F001" to 2, "F002" to 1)) }
    var voucherCode by remember { mutableStateOf("") }

    val items = listOf(
        Triple("F001", "Nasi Goreng Spesial", 45000),
        Triple("F002", "Es Teh Manis", 5000),
    )

    val subtotal = items.sumOf { (id, _, price) -> (quantities[id] ?: 1) * price }
    val deliveryFee = 7000
    val total = subtotal + deliveryFee

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Keranjang", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
        bottomBar = {
            Surface(shadowElevation = 8.dp) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                    ) {
                        Text("Total", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                        Text("Rp$total", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = ClayPrimary)
                    }
                    Spacer(Modifier.height(12.dp))
                    Button(
                        onClick = onCheckout,
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape = RoundedCornerShape(12.dp),
                    ) {
                        Text("Checkout (${quantities.values.sum()} item)", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            }
        },
    ) { padding ->
        if (items.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Default.ShoppingCart, contentDescription = null, modifier = Modifier.size(64.dp), tint = Grey300)
                    Spacer(Modifier.height(16.dp))
                    Text("Keranjang kosong", fontWeight = FontWeight.Medium, color = Grey500)
                    Text("Yuk, pesan makanan favoritmu!", style = MaterialTheme.typography.bodySmall, color = Grey400)
                }
            }
        } else {
            Column(
                modifier = Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp),
            ) {
                Card(shape = RoundedCornerShape(12.dp)) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Warung Nusantara", fontWeight = FontWeight.Bold)
                        Spacer(Modifier.height(8.dp))
                        items.forEach { (id, name, price) ->
                            Row(
                                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                                verticalAlignment = Alignment.CenterVertically,
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text(name, fontWeight = FontWeight.Medium)
                                    Text("Rp$price", color = Grey500, style = MaterialTheme.typography.bodySmall)
                                }
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    IconButton(onClick = { quantities = quantities + (id to maxOf((quantities[id] ?: 1) - 1, 0)) }) {
                                        Icon(Icons.Default.RemoveCircleOutline, contentDescription = null, tint = ClayPrimary)
                                    }
                                    Text("${quantities[id] ?: 1}", fontWeight = FontWeight.Bold)
                                    IconButton(onClick = { quantities = quantities + (id to (quantities[id] ?: 1) + 1) }) {
                                        Icon(Icons.Default.AddCircle, contentDescription = null, tint = ClayPrimary)
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer(Modifier.height(16.dp))

                Card(shape = RoundedCornerShape(12.dp)) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Voucher", fontWeight = FontWeight.SemiBold)
                        Spacer(Modifier.height(8.dp))
                        OutlinedTextField(
                            value = voucherCode,
                            onValueChange = { voucherCode = it },
                            placeholder = { Text("Masukkan kode promo") },
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(12.dp),
                            singleLine = true,
                            trailingIcon = {
                                TextButton(enabled = voucherCode.isNotBlank()) { Text("Pakai") }
                            },
                        )
                    }
                }

                Spacer(Modifier.height(16.dp))

                Card(shape = RoundedCornerShape(12.dp)) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Ringkasan Pesanan", fontWeight = FontWeight.SemiBold)
                        Spacer(Modifier.height(12.dp))
                        Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Subtotal", color = Grey500); Text("Rp$subtotal") }
                        Spacer(Modifier.height(4.dp))
                        Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Biaya pengiriman", color = Grey500); Text("Rp$deliveryFee") }
                        Spacer(Modifier.height(4.dp))
                        HorizontalDivider()
                        Spacer(Modifier.height(4.dp))
                        Row(Modifier.fillMaxWidth(), Arrangement.SpaceBetween) { Text("Total", fontWeight = FontWeight.Bold); Text("Rp$total", fontWeight = FontWeight.Bold, color = ClayPrimary) }
                    }
                }

                Spacer(Modifier.height(80.dp))
            }
        }
    }
}
