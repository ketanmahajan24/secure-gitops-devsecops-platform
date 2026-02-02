pipeline {
    agent any

    environment {
        IMAGE_NAME = "computer-academy-webapp"
        IMAGE_TAG  = "latest"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        APP_PORT = "3000"
        CONTAINER_NAME = "computer-academy-webapp"
        FULL_IMAGE = "ketanmahajan24/computer-academy-webapp"
        SONARQUBE_ENV = "SonarQube"
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        // ---------------- CHECKOUT ----------------
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Source Code Overview') {
            steps {
                echo "Listing project files:"
                sh 'ls -la'
            }
        }

        // ---------------- INSTALL DEPENDENCIES ----------------
        stage('Install Dependencies') {
            steps {
                dir('Computer-Academy-Management') {
                    sh 'npm install'
                }
            }
        }

        // ---------------- SAST (SonarQube) ----------------
        stage('SonarQube Code Analysis') {
            steps {
                dir('Computer-Academy-Management') {
                    withSonarQubeEnv("${SONARQUBE_ENV}") {
                        script {
                            def scannerHome = tool 'sonar-scanner'
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=computer-academy \
                                -Dsonar.sources=. \
                                -Dsonar.language=js \
                                -Dsonar.host.url=http://65.0.124.62:9000 \
                                -Dsonar.login=${SONAR_AUTH_TOKEN}
                            """
                        }
                    }
                }
            }
        }

        // ---------------- SCA (OWASP Dependency-Check) ----------------
        stage('OWASP Dependency Check') {
    steps {
        dir('Computer-Academy-Management') {
            script {
                def dcHome = tool 'OWASP-Dependency-Check'
                sh """
                  mkdir -p dependency-check-report
                    ${dcHome}/bin/dependency-check.sh \
                      --scan . \
                      --format XML \
                      --format HTML \
                      --out dependency-check-report \
                      --failOnCVSS 9 \
                      --suppression dependency-check-suppressions.xml \
                      --disableAssembly \
                      --exclude node_modules \
                      --exclude dist \
                      --exclude .git
                """
            }
        }
    }
}

        // ---------------- DOCKER BUILD ----------------
        stage('Build Docker Image') {
            steps {
                dir('Computer-Academy-Management') {
                    sh """
                        docker build -t ${FULL_IMAGE}:${BUILD_NUMBER} .
                        docker tag ${FULL_IMAGE}:${BUILD_NUMBER} ${FULL_IMAGE}:latest
                    """
                }
            }
        }

        // ---------------- TRIVY IMAGE SCAN ----------------
        stage('Trivy Image Scan') {
            steps {
                echo "🔐 Scanning Docker image with Trivy"
                sh """
                    trivy image \
                      --severity HIGH,CRITICAL \
                      --format html \
                      --output trivy-report.html \
                      ${FULL_IMAGE}:latest

                    trivy image \
                      --exit-code 1 \
                      --severity HIGH,CRITICAL \
                      ${FULL_IMAGE}:latest
                """
            }
        }

        // ---------------- DOCKER PUSH ----------------
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
                sh "docker push ${FULL_IMAGE}:latest"
            }
        }

        // ---------------- DEPLOY ----------------
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
                          -e MONGO_URL=${MONGO_URL} \
                          -e PORT=${APP_PORT} \
                          ${FULL_IMAGE}:latest
                    """
                }
            }
        }
    }

    post {
        always {
            // Publish Dependency-Check report
            dependencyCheckPublisher pattern: 'Computer-Academy-Management/dependency-check-report/dependency-check-report.xml'

            // Archive Trivy report
            archiveArtifacts artifacts: 'trivy-report.html', fingerprint: true

            // Logout from Docker
            sh 'docker logout || true'
        }

        success {
            echo "✅ Pipeline completed successfully: App deployed with full DevSecOps checks!"
        }

        failure {
            echo "❌ Pipeline failed due to security or quality issues."
        }
    }
}
