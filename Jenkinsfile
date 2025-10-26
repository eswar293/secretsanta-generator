pipeline {
    agent any
    tools {
        jdk 'jdk-17'
        maven 'maven'
    }

    environment {
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/eswar293/secretsanta-generator.git'
            }
        }
        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('owasp scan') {
            steps {
                dependencyCheck additionalArguments: '--scan ./', odcInstallation: 'DC'
                                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Buil Application') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}
