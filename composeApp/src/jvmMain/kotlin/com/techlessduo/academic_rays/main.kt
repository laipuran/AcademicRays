package com.techlessduo.academic_rays

import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application

fun main() = application {
    Window(
        onCloseRequest = ::exitApplication,
        title = "academic_rays",
    ) {
        App()
    }
}