allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val configureCompileSdk: () -> Unit = {
        if (project.hasProperty("android")) {
            val androidExt = project.extensions.findByName("android")
            if (androidExt != null) {
                try {
                    val method = androidExt.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    method.invoke(androidExt, 36)
                } catch (_: Throwable) {
                    try {
                        val setMethod = androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                        setMethod.invoke(androidExt, 36)
                    } catch (_: Throwable) {}
                }
            }
        }
    }

    if (project.state.executed) {
        configureCompileSdk()
    } else {
        project.afterEvaluate { configureCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
