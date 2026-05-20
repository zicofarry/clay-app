package com.clay.core.network.api

import com.clay.core.model.Address
import com.clay.core.model.User
import retrofit2.http.*

interface UserApi {
    @GET("api/v1/users/me")
    suspend fun getProfile(): User

    @PUT("api/v1/users/me")
    suspend fun updateProfile(@Body request: UpdateProfileRequest): User

    @GET("api/v1/addresses")
    suspend fun getAddresses(): List<Address>

    @POST("api/v1/addresses")
    suspend fun createAddress(@Body address: Address): Address
}

data class UpdateProfileRequest(val name: String? = null, val email: String? = null)
