pipeline {
  agent any

  environment {
    IMAGE = "vinu890/sample-app"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Test') {
      steps {
        sh './test.sh'
      }
    }

    stage('Build Docker') {
      steps {
        script {
          def tag = (env.GIT_COMMIT ?: "local").take(7)
          sh "docker build -t ${IMAGE}:${tag} ."
          env.IMG_TAG = "${IMAGE}:${tag}"
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
          sh "docker push ${env.IMG_TAG}"
        }
      }
    }

stage('Deploy (SSH)') {
    steps {
        sshagent(['ssh-credentials']) {
            sh '''
                ssh -o StrictHostKeyChecking=no projects@localhost "docker pull vinu890/sample-app:${GIT_COMMIT}"
                ssh -o StrictHostKeyChecking=no projects@localhost "docker stop sample-app || true && docker rm sample-app || true"
                ssh -o StrictHostKeyChecking=no projects@localhost "docker run -d --name sample-app -p 8080:8080 vinu890/sample-app:${GIT_COMMIT}"
            '''
        }
    }
}


  post {
    always {
      archiveArtifacts artifacts: 'index.html', fingerprint: true
    }
  }
}
