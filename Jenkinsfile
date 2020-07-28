pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        sh '''echo \'HelloWorld\'
cmake --version'''
        cmake(installation: 'CMakeDefault', workingDir: 'build')
      }
    }

  }
}