pipeline {
    agent any
    
    environment {
        DOCKER_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_IMAGE = 'caroline1105/java-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }
    
    tools {
        jdk 'JDK-17'  // For building
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build with Java 17') {
            steps {
                sh 'javac src/Main.java'
            }
        }
          stage('Run Tests with Java 11') {
            tools {
                jdk 'JDK-11'
            }
            steps {
                sh '''
                    # Create lib directory if it doesn't exist
                    mkdir -p lib
                    
                    # Download JUnit and Hamcrest if they don't exist
                    if [ ! -f lib/junit-4.13.2.jar ]; then
                        curl -L https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar -o lib/junit-4.13.2.jar
                    fi
                    if [ ! -f lib/hamcrest-core-1.3.jar ]; then
                        curl -L https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar -o lib/hamcrest-core-1.3.jar
                    fi
                    
                    # Run tests
                    javac -cp "lib/junit-4.13.2.jar:." src/MyTests.java src/Main.java
                    java -cp "lib/junit-4.13.2.jar:lib/hamcrest-core-1.3.jar:.:src" org.junit.runner.JUnitCore MyTests
                '''
            }
        }
        
        stage('Code Quality Analysis with Java 8') {
            tools {
                jdk 'JDK-8'
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                            -Dsonar.projectKey=java-app \
                            -Dsonar.sources=src \
                            -Dsonar.java.binaries=. \
                            -Dsonar.host.url=http://your-sonarqube-url:9000
                    '''
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")
                }
            }
        }
        
        stage('Push to Docker Registry') {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push()
                        docker.image("${DOCKER_IMAGE}:${DOCKER_TAG}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubernetes-credentials']) {
                        sh '''
                            sed -i "s|java-app:latest|${DOCKER_IMAGE}:${DOCKER_TAG}|g" deployment.yaml
                            kubectl apply -f deployment.yaml
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
