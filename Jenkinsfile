pipeline {
    agent any

    environment {
        IMAGE_NAME = "computer-academy-webapp"
        IMAGE_TAG  = "latest"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        APP_PORT = "3000"
        CONTAINER_NAME = "computer-academy-webapp"
        FULL_IMAGE = "ketanmahajan24/computer-academy-webapp"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        	stage ('source code checkout'){
			steps{
				echo " source code contains below files " 
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
stage('Build Docker Image') {
    steps {
        dir('Computer-Academy-Management') {
            withCredentials([usernamePassword(
                credentialsId: DOCKER_CREDENTIALS_ID,
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {
                sh '''
                docker build -t ${FULL_IMAGE}:$BUILD_NUMBER .
                docker tag ${FULL_IMAGE}:$BUILD_NUMBER ${FULL_IMAGE}:latest
                '''
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
        withCredentials([usernamePassword(
            credentialsId: DOCKER_CREDENTIALS_ID,
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            sh '''
            docker push ${FULL_IMAGE}:latest
            '''
        }
    }
}
        stage('Deploy Container') {
            steps {
                withCredentials([string(credentialsId: 'mongo-url', variable: 'MONGO_URL')]) { 
                    sh '''
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true

                    docker pull ${FULL_IMAGE}:latest

                    docker run -d \
                    -p ${APP_PORT}:${APP_PORT} \
                    --name ${CONTAINER_NAME} \
                    -e MONGO_URL=$MONGO_URL \
                    -e PORT=${APP_PORT} \
                    ${FULL_IMAGE}:latest
                    '''
                }
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
