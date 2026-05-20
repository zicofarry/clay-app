package com.clay.feature.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
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
fun OtpScreen(
    onBack: () -> Unit,
    onVerifySuccess: () -> Unit,
) {
    var otp by remember { mutableStateOf("") }
    var timer by remember { mutableIntStateOf(60) }
    var isTimerRunning by remember { mutableStateOf(true) }

    LaunchedEffect(isTimerRunning) {
        if (isTimerRunning) {
            while (timer > 0) {
                kotlinx.coroutines.delay(1000)
                timer--
            }
            isTimerRunning = false
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Verifikasi OTP") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
            )
        },
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
        ) {
            Spacer(Modifier.height(32.dp))

            Text(
                "Masukkan Kode OTP",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
            )
            Spacer(Modifier.height(8.dp))
            Text(
                "Kode verifikasi telah dikirim ke nomor HP Anda",
                style = MaterialTheme.typography.bodyMedium,
                color = Grey500,
                textAlign = TextAlign.Center,
            )

            Spacer(Modifier.height(40.dp))

            OutlinedTextField(
                value = otp,
                onValueChange = { if (it.length <= 6) otp = it },
                label = { Text("Kode OTP") },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                singleLine = true,
                textAlign = TextAlign.Center,
                supportingText = { Text("Masukkan 6 digit kode") },
            )

            Spacer(Modifier.height(24.dp))

            Button(
                onClick = onVerifySuccess,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape = RoundedCornerShape(12.dp),
                enabled = otp.length == 6,
            ) {
                Text("Verifikasi", fontSize = 16.sp)
            }

            Spacer(Modifier.height(24.dp))

            if (timer > 0) {
                Text(
                    "Kirim ulang dalam $timer detik",
                    color = Grey500,
                )
            } else {
                TextButton(onClick = {
                    timer = 60
                    isTimerRunning = true
                }) {
                    Text("Kirim ulang OTP", color = ClayPrimary)
                }
            }
        }
    }
}
