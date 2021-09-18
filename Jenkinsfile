pipeline {
    agent any

    stages {
        
        stage("Docker Build") {
            steps {
                sh 'docker build -t myregistry.domain.com:5000/dockerpets:v${BUILD_NUMBER} .'
            }
        }

        stage("Docker Login") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'REGISRTY_CREDENTIALS', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    sh 'docker login myregistry.domain.com:5000 -u $USERNAME -p $PASSWORD'
                }
            }
        }

        stage("Docker Push") {
            steps {
                sh 'docker push myregistry.domain.com:5000/dockerpets:v${BUILD_NUMBER}'
            }
        }

        stage("Kubernetes Deployment") {
            steps {
                script {
                        env.DOCKER_BUILD_NUMBER="${BUILD_NUMBER}"
                        sh 'echo ${DOCKER_BUILD_NUMBER}'
                        sh 'envsubst < ./web-pet1.yml | kubectl apply -f -'
                     
                }
            }
        }
    }
}
