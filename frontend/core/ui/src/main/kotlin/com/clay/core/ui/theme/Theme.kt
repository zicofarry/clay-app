package com.clay.core.ui.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = ClayPrimary,
    onPrimary = ClayOnPrimary,
    primaryContainer = Blue100,
    secondary = ClaySecondary,
    background = ClayBackground,
    surface = ClaySurface,
    error = ClayError,
    onBackground = ClayOnBackground,
    onSurface = ClayOnSurface,
    surfaceVariant = Grey100,
    outline = Grey300,
)

private val DarkColorScheme = darkColorScheme(
    primary = Blue300,
    onPrimary = Blue900,
    primaryContainer = Blue800,
    secondary = Green500,
    background = Grey900,
    surface = Grey800,
    error = Red500,
    onBackground = Grey50,
    onSurface = Grey100,
    surfaceVariant = Grey700,
    outline = Grey500,
)

@Composable
fun ClayTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = ClayTypography,
        content = content,
    )
}
