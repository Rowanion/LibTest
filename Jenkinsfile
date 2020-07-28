pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        cmakeBuild(installation: 'CMakeDefault', buildDir: 'build', buildType: 'Debug', cleanBuild: true, generator: 'Visual Studio 16 2019', cmakeArgs: '-A x64')
        cmake(installation: 'CMakeDefault', arguments: '--build build')
      }
    }

  }
}