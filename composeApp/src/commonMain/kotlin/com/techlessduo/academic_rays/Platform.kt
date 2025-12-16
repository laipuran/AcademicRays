package com.techlessduo.academic_rays

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform