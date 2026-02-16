package com.example.app

data class LockConfiguration(
    val strictnessMode: String,
    val lockBeforeMinutes: Int,
    val lockAfterMinutes: Int,
)
