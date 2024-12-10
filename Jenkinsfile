pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'
      label 'jenkins-agent'
      defaultContainer 'docker'
      yaml """
---
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins
spec:
  containers:
    - name: k8s
      image: alpine/k8s:1.29.11
      command:
        - /bin/cat
      tty: true
    - name: docker
      image: docker:latest
      command:
        - /bin/cat
      tty: true
      volumeMounts:
        - name: dind-certs
          mountPath: /certs
      env:
        - name: DOCKER_TLS_CERTDIR
          value: /certs
        - name: DOCKER_CERT_PATH
          value: /certs
        - name: DOCKER_TLS_VERIFY
          value: 1
        - name: DOCKER_HOST
          value: tcp://localhost:2376
        - name: registryUser
          valueFrom:
            secretKeyRef:
              name: registry
              key: User
        - name: registryPassword
          valueFrom:
            secretKeyRef:
              name: registry
              key: Password
        - name: registryUrl
          valueFrom:
            secretKeyRef:
              name: registry
              key: Url
    - name: dind
      image: docker:dind
      securityContext:
        privileged: true
      env:
        - name: DOCKER_TLS_CERTDIR
          value: /certs
      volumeMounts:
        - name: dind-storage
          mountPath: /var/lib/docker
        - name: dind-certs
          mountPath: /certs/client
  volumes:
    - name: dind-storage
      emptyDir: {}
    - name: dind-certs
      emptyDir: {}
"""
    }
  }
  stages {
    stage('Run Docker Things') {
      steps {
        sh '''
            set -e
            ls -arlt
            cd docker-pets
            commitid=$(git log -1 --format=%h)
            docker build -t $registryUrl/docker-pet:latest -t $registryUrl/docker-pet:$commitid .
            docker images 
            echo "**************"
            echo "Docker login"
            echo $registryPassword | docker login -u $registryUser $registryUrl --password-stdin
            echo "Docker pushing images"
            docker push $registryUrl/docker-pet:latest
            docker push $registryUrl/docker-pet:$commitid
            
        '''
      }
    }
  }
}
