pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = "ketanmahajan24"
        IMAGE_NAME = "computer-academy-webapp"
        IMAGE_TAG  = "latest"
        FULL_IMAGE = "${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"

        APP_PORT = "3000"
        MONGO_URL = "mongodb://10.0.2.177:27017/computer_academy"
        CONTAINER_NAME = "computer-academy-webapp"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('Computer-Academy-Management') {
                    sh 'npm install'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('Computer-Academy-Management') {
                    sh '''
                    docker build -t ${FULL_IMAGE} .
                    '''
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDENTIALS_ID,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh 'docker push ${FULL_IMAGE}'
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                docker pull ${FULL_IMAGE}

                docker run -d \
                  -p ${APP_PORT}:${APP_PORT} \
                  --name ${CONTAINER_NAME} \
                  -e MONGO_URL=${MONGO_URL} \
                  -e PORT=${APP_PORT} \
                  ${FULL_IMAGE}
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Application deployed successfully on port 3000"
        }
        failure {
            echo "❌ Pipeline failed"
        }
        always {
            sh 'docker logout || true'
        }
    }
}
