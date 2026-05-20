package com.clay.feature.wallet

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
fun TopUpScreen(onBack: () -> Unit) {
    var customAmount by remember { mutableStateOf("") }
    var selectedAmount by remember { mutableIntStateOf(-1) }
    var selectedMethod by remember { mutableIntStateOf(0) }

    val amounts = listOf(50000, 100000, 200000, 500000, 1000000, 2000000)
    val methods = listOf("BCA Virtual Account", "Mandiri Virtual Account", "BNI Virtual Account", "GoPay", "OVO", "DANA", "Indomaret", "Alfamart")

    Scaffold(
        topBar = { TopAppBar(title = { Text("Top Up", fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Default.ArrowBack, contentDescription = "Back") } }) },
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding).background(MaterialTheme.colorScheme.background).verticalScroll(rememberScrollState()).padding(16.dp)) {
            Text("Pilih Nominal", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(12.dp))
            amounts.chunked(3).forEach { row ->
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    row.forEach { amount ->
                        val index = amounts.indexOf(amount)
                        Card(
                            modifier = Modifier.weight(1f).clickable { selectedAmount = index; customAmount = "" },
                            shape = RoundedCornerShape(12.dp),
                            colors = if (selectedAmount == index) CardDefaults.cardColors(containerColor = Blue50) else CardDefaults.cardColors(),
                            border = if (selectedAmount == index) CardDefaults.outlinedCardBorder().copy(width = 1.dp) else null,
                        ) {
                            Text("Rp${amount / 1000}rb", modifier = Modifier.padding(16.dp).fillMaxWidth(), textAlign = TextAlign.Center, fontWeight = FontWeight.Medium)
                        }
                    }
                }
                Spacer(Modifier.height(8.dp))
            }

            OutlinedTextField(
                value = customAmount,
                onValueChange = { customAmount = it; selectedAmount = -1 },
                label = { Text("Jumlah Lain") },
                leadingIcon = { Text("Rp", fontWeight = FontWeight.Bold) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
            )

            Spacer(Modifier.height(24.dp))
            Text("Metode Pembayaran", fontWeight = FontWeight.Bold, style = MaterialTheme.typography.titleMedium)
            Spacer(Modifier.height(12.dp))

            methods.forEachIndexed { index, method ->
                Row(
                    modifier = Modifier.fillMaxWidth().clickable { selectedMethod = index }.padding(vertical = 10.dp),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    RadioButton(selected = selectedMethod == index, onClick = { selectedMethod = index })
                    Spacer(Modifier.width(8.dp))
                    Text(method)
                }
            }

            Spacer(Modifier.height(24.dp))
            Button(
                onClick = { onBack() },
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(12.dp),
                enabled = selectedAmount >= 0 || customAmount.isNotBlank(),
            ) {
                Text("Top Up Sekarang", fontWeight = FontWeight.Bold)
            }
        }
    }
}
