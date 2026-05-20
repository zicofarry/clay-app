pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    @Suppress("UnstableApiUsage")
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "clay"

include(":app")

include(":core:ui")
include(":core:network")
include(":core:model")
include(":core:data")
include(":core:common")

include(":feature:auth")
include(":feature:home")
include(":feature:ride")
include(":feature:food")
include(":feature:send")
include(":feature:services")
include(":feature:profile")
include(":feature:activity")
include(":feature:chat")
include(":feature:wallet")
include(":feature:notifications")
