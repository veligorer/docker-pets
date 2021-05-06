pipeline {
    agent { label 'ubuntu' }

    stages {

        stage("Checkout Code") {
            steps {
                cleanWs()
                git branch: 'master', 
                credentialsId: 'GIT_HUB_CREDENTIALS', 
                url: 'https://github.com/veligorer/docker-pets.git'
            }
        }

        stage("Docker Build") {
            steps {
                sh 'docker build -t gorerveli.azurecr.io/dockerpets:v${BUILD_NUMBER} .'
            }
        }

        stage("Docker Login") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'AZURE_CREDENTIALS', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    sh 'docker login gorerveli.azurecr.io -u $USERNAME -p $PASSWORD'
                }
            }
        }

        stage("Docker Push") {
            steps {
                sh 'docker push gorerveli.azurecr.io/dockerpets:v${BUILD_NUMBER}'
            }
        }

        stage("Kubernetes Deployment") {
            steps {
                script {
                        env.DOCKER_BUILD_NUMBER="${BUILD_NUMBER}"
                        sh 'echo ${DOCKER_BUILD_NUMBER}'
                        sh 'envsubst < ./web-pet1.yml | kubectl apply -f -'
                        sh 'envsubst < ./web-pet2.yml | kubectl apply -f -'
                     
                }
            }
        }
    }
}