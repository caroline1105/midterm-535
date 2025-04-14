pipeline {
    agent any

    tools {
        jdk 'Java 17'
    }

    environment {
        SCANNER_HOME = tool 'SonarQubeScanner'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/caroline1105/midterm-535.git'
            }
        }

        stage('Build') {
            steps {
                bat 'javac src\\Main.java'
            }
        }

        stage('Test') {
            steps {
                bat '''
                    if not exist lib mkdir lib
                    curl -L -o lib\\junit-4.13.2.jar https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar
                    curl -L -o lib\\hamcrest-core-1.3.jar https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar
                    javac -cp "lib\\junit-4.13.2.jar;." src\\MyTests.java src\\Main.java
                    java -cp "lib\\junit-4.13.2.jar;lib\\hamcrest-core-1.3.jar;.;src" org.junit.runner.JUnitCore MyTests
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    bat "\"${env.SCANNER_HOME}\\bin\\sonar-scanner.bat\" -Dsonar.projectKey=java-app -Dsonar.sources=src -Dsonar.java.binaries=."
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t java-app .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat '''
                        docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                        docker tag java-app %DOCKER_USER%/java-app
                        docker push %DOCKER_USER%/java-app
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                bat 'kubectl apply -f k8s/deployment.yaml'
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
