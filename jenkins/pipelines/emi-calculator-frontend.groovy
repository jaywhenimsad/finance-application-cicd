pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE = 'jaycontainers328/finance-app-cicd'
        KUBERNETES_DEPLOYMENT = 'emi-frontend-deployment'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/jaywhenimsad/finance-application-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('App Code/emi/frontend') {
                    script {
                        env.TAG = "emi-calc-frontend-${env.BUILD_NUMBER}"
                        sh "docker build -t $DOCKER_IMAGE:$TAG -t $DOCKER_IMAGE:emi-calc-frontend ."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/']) {
                        sh "docker push $DOCKER_IMAGE:$TAG"
                        sh "docker push $DOCKER_IMAGE:emi-calc-frontend"
                    }
                }
            }
        }

        stage('Rolling Update Kubernetes Deployment') {
            steps {
                script {
                    sh "kubectl set image deployment/$KUBERNETES_DEPLOYMENT emi-frontend=$DOCKER_IMAGE:$TAG"
                    sh "kubectl rollout status deployment/$KUBERNETES_DEPLOYMENT --timeout=120s"
                }
            }
        }
    }
}
