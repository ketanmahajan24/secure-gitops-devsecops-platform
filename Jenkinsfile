pipeline {
    agent any

    environment {
        IMAGE_NAME = "computer-academy-webapp"
        IMAGE_TAG  = "latest"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        APP_PORT = "3000"
        CONTAINER_NAME = "computer-academy-webapp"
        FULL_IMAGE = "ketanmahajan24/computer-academy-webapp"
        SONAR_PROJECT_KEY = "computer-academy-webapp"
        SONAR_HOST_URL = "http://10.0.1.106:9000" // SonarQube Docker IP
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Source Code Verification') {
            steps {
                echo "Source code contains below files:"
                sh 'ls -la'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('Computer-Academy-Management') {
                    sh 'npm install'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('Computer-Academy-Management') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        echo "🔍 Running SonarScanner in Docker..."
                        sh '''
                            docker run --rm \
                                -e SONAR_HOST_URL=${SONAR_HOST_URL} \
                                -e SONAR_LOGIN=$SONAR_TOKEN \
                                -v "$PWD":/usr/src \
                                sonarsource/sonar-scanner-cli
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('Computer-Academy-Management') {
                    withCredentials([usernamePassword(
                        credentialsId: DOCKER_CREDENTIALS_ID,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh """
                            docker build -t ${FULL_IMAGE}:${BUILD_NUMBER} .
                            docker tag ${FULL_IMAGE}:${BUILD_NUMBER} ${FULL_IMAGE}:latest
                        """
                    }
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
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                }
            }
        }

        stage('Push Image to Docker Hub') {
            steps {
                sh """
                    docker push ${FULL_IMAGE}:${BUILD_NUMBER}
                    docker push ${FULL_IMAGE}:latest
                """
            }
        }

        stage('Deploy Container') {
            steps {
                withCredentials([string(credentialsId: 'mongo-url', variable: 'MONGO_URL')]) {
                    sh """
                        docker stop ${CONTAINER_NAME} || true
                        docker rm ${CONTAINER_NAME} || true

                        docker pull ${FULL_IMAGE}:latest

                        docker run -d \
                            -p ${APP_PORT}:${APP_PORT} \
                            --name ${CONTAINER_NAME} \
                            -e MONGO_URL=$MONGO_URL \
                            -e PORT=${APP_PORT} \
                            ${FULL_IMAGE}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Application deployed successfully on port ${APP_PORT}"
        }
        failure {
            echo "❌ Pipeline failed (possibly due to SonarQube Quality Gate or Docker errors)"
        }
        always {
            sh 'docker logout || true'
        }
    }
}
