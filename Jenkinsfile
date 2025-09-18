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
        sshagent(['deploy-ssh']) {
          sh """
            ssh -o StrictHostKeyChecking=no projects@localhost \
              "docker pull ${env.IMG_TAG} && \
               docker stop sample-app || true && \
               docker rm sample-app || true && \
               docker run -d --name sample-app -p 8081:8080 ${env.IMG_TAG}"
          """
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'index.html', fingerprint: true
    }
  }
}
