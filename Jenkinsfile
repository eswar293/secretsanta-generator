pipeline {
    agent any

    tools {
        maven 'mvn-3.9'
        jdk 'jdk-21'
    }

    environment {
        SCANNER_HOME = tool 'sonarqube'
        IMAGE_NAME = "eswar1241"
        
    }

    stages {
        stage('Clean the workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/eswar293/secretsanta-generator.git'
            }
        }

        stage('Compiling the Code') {
            steps {
                sh 'mvn clean compile'
            }
        }


        stage('Test the Code') {
            steps {
                sh 'mvn test'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: ' --scan ./ ', odcInstallation: 'DC'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy filesystem scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'sonar-scanner -Dsonar.projectName=santa -Dsonar.projectKey=santa -Dsonar.java.binaries=target/classes'
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    timeout(3) {
                        waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
                    }
                }
                
            }
        }

        stage('Build Application') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Deploy to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'global-setting', jdk: 'jdk-21', maven: 'mvn-3.9', traceability: true) {
                    sh 'mvn deploy'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred' , url: '') {
                    sh "docker build -t $IMAGE_NAME/${env.JOB_NAME}:latest-v${BUILD_NUMBER} ."
                    }
                }
            }
        }

        stage('Trivy Image scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html $IMAGE_NAME/${env.JOB_NAME}:latest-v${env.BUILD_NUMBER}"
            }
        }

        stage('Docker push and Run') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker-cred' , url: '') {
                    sh "docker push $IMAGE_NAME/${env.JOB_NAME}:latest-v${BUILD_NUMBER}"
                    sh "docker run -d --name santa -p 80:8080 $IMAGE_NAME/${env.JOB_NAME}:latest-v${BUILD_NUMBER}"
                    }
                }
            }
        }   
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
                
                def body = """
                    <html>
                    <body>
                    <div style="border: 4px solid ${bannerColor}; padding: 10px;">
                    <h2>${jobName} - Build ${buildNumber}</h2>
                    <div style="background-color: ${bannerColor}; padding: 10px;">
                    <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                    </div>
                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                    </div>
                    </body>
                    </html>
                """
            }
        }
    }
}
    
    
