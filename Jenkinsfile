pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        cmake(installation: 'CMakeDefault', workingDir: 'build')
      }
    }

  }
}