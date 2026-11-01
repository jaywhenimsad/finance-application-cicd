pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        DOCKER_IMAGE          = 'jaycontainers328/finance-app-cicd'

        // ---- change these per module ----
        MODULE_PATH           = 'App Code/emi/backend'
        TAG_PREFIX            = 'emi-backend'
        K8S_DEPLOYMENT        = 'emi-backend-deployment'
        K8S_CONTAINER         = 'emi-backend'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'master', url: 'https://github.com/jaywhenimsad/finance-application-cicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                dir("${MODULE_PATH}") {
                    script {
                        env.TAG = "${TAG_PREFIX}-${env.BUILD_NUMBER}"
                        sh "docker build -t $DOCKER_IMAGE:$TAG -t $DOCKER_IMAGE:$TAG_PREFIX ."
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'dockerhub', url: 'https://index.docker.io/v1/']) {
                        sh "docker push $DOCKER_IMAGE:$TAG"
                        sh "docker push $DOCKER_IMAGE:$TAG_PREFIX"
                    }
                }
            }
        }

        stage('Rolling Update Kubernetes Deployment') {
            steps {
                sh "kubectl set image deployment/$K8S_DEPLOYMENT $K8S_CONTAINER=$DOCKER_IMAGE:$TAG"
                sh "kubectl rollout status deployment/$K8S_DEPLOYMENT --timeout=120s"
            }
        }
    }
}