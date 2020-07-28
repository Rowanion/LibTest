pipeline {
  agent any
  stages {
    stage('Configure') {
      steps {
        cmakeBuild(installation: 'CMakeDefault', buildDir: 'build', buildType: 'Debug', cleanBuild: true, generator: 'Visual Studio 16 2019', cmakeArgs: '-A x64')
      }
    }

    stage('Build') {
      steps {
        cmake(arguments: '--build build --target ALL_BUILD', installation: 'CMakeDefault')
      }
    }

    stage('Test') {
      steps {
        sleep(unit: 'MILLISECONDS', time: 1)
      }
    }

    stage('Deploy') {
      steps {
        sleep(unit: 'MILLISECONDS', time: 1)
      }
    }

  }
}