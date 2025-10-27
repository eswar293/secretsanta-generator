pipeline {
    agent any
    tools {
        jdk 'jdk-21'
        maven 'mvn-3.9'
    }

    environment {
        SCANNER_HOME = tool 'sonarqube'
    }
    stages {
        stage('Code Checkout') {
            steps {
                git branch: 'main', changelog: false, poll: false, url: 'https://github.com/eswar293/secretsanta-generator.git'
            }
        }
        
        stage('Code Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Code Test') {
            steps {
                sh 'mvn test'
            }
        }


        stage('Sonar Scan for Quality checks') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=santa -Dsonar.projectKey=santa -Dsonar.java.binaries=. '''
                }
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage ('Docker Build') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker build -t  eswar1241/santa:${BUILD_NUMBER} . "
                    }
                }
            }
        }

        stage ('Docker push') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred') {
                    sh "docker push eswar1241/santa:${BUILD_NUMBER}"
                    }
                }
            }
        }

        stage ('Trivy image scan') {
            steps {
                sh "trivy image eswar1241/santa:${BUILD_NUMBER}"
            }
        }
    }
}