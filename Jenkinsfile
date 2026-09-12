pipeline {
    agent any
    tools {
        jdk'jdk8'
        maven'mvn3.9'
    }
    environment {
        SONAR_HOME = tool'sonarqube'
        IMAGE_NAME = "eswar1241/${env.JOB_NAME}"
        IMAGE_TAG = "v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clean workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/eswar293/secretsanta-generator.git'
            }
        }
        stage('Compile the Code') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage('Test the Code') {
            steps {
                sh 'mvn test'
            }
        }
        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs --format table -o filesystem-report.html .'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh ''' $SONAR_HOME/bin/sonar-scanner -Dsonar.projectName=Santa -Dsonar.projectKey=Santa \
                            -Dsonar.java.binaries=. '''
                }
            }
        }
        stage('Code Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
            }
        }
        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Artifact push to nexus') {
            steps {
               withMaven(globalMavenSettingsConfig: 'global-settings', jdk: 'jdk8', maven: 'mvn3.9', traceability: true) {
                   sh 'mvn deploy'
               }
            }
        }
        stage('Build Docker Image') {
            steps {
                withDockerRegistry(credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/') {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} . "
                }
            }
        }
        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o docker-scan-image.html ${IMAGE_NAME}:${IMAGE_TAG} "
            }
        }
        stage('Push to Docker Repo') {
            steps {
                withDockerRegistry(credentialsId: 'docker-cred', url: 'https://index.docker.io/v1/') {
                    sh "docker push ${IMAGE_NAME}:${IMAGE_TAG} "
                }
            }
        }
        stage('Run Docker Container') {
            steps {
                sh 'docker run -d -p 8081:8080 --name santa ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
    }
}
