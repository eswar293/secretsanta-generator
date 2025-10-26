pipeline {
    agent any
    tools {
        jdk 'jdk-21'
        maven 'mvn-3.9'
    }

    environment {
        SCANNER_HOME = tool 'Sonarqube'
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

        stage('OWASP Depedency Check') { 
            steps {
                dependencyCheck additionalArguments: '--scan ./ ', odcInstallation: 'DC'
                dependencyCheckPublisher pattern: '**/depedency-check-report.xml'
            }
        }

        stage('Sonar Scan for Quality checks') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh ''' $SCANNER_HOME/bin/sonarqube -Dsonar.projectName=santa -Dsonar.projectKey=santa -Dsonar.java.binaries=. '''
                }
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}