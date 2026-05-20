package com.clay.core.network.api

import retrofit2.http.*

interface AuthApi {
    @POST("api/v1/auth/register")
    suspend fun register(@Body request: RegisterRequest): AuthResponse

    @POST("api/v1/auth/login")
    suspend fun login(@Body request: LoginRequest): AuthResponse

    @POST("api/v1/auth/refresh")
    suspend fun refreshToken(@Body request: RefreshRequest): AuthResponse

    @POST("api/v1/auth/logout")
    suspend fun logout(@Header("Authorization") token: String)

    @POST("api/v1/auth/otp/request")
    suspend fun requestOtp(@Body request: OtpRequest): OtpResponse

    @POST("api/v1/auth/otp/verify")
    suspend fun verifyOtp(@Body request: OtpVerifyRequest): OtpVerifyResponse
}

data class RegisterRequest(val name: String, val email: String, val phone: String, val password: String)
data class LoginRequest(val identifier: String, val password: String)
data class RefreshRequest(val refreshToken: String)
data class OtpRequest(val phone: String)
data class OtpVerifyRequest(val phone: String, val otp: String)
data class AuthResponse(val token: String, val refreshToken: String, val userId: String)
data class OtpResponse(val expiresIn: Int)
data class OtpVerifyResponse(val verified: Boolean)
