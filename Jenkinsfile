pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'
      label 'jenkins-agent'
      defaultContainer 'docker'
    }
  }
  stages {
    stage('Run Docker Things') {
      steps {
        container('docker') {
        sh '''
            set -e
            env
            ls -arlt
            git config --global --add safe.directory $PWD
            commitid=$(git log -1 --format=%h)
            echo $commitid
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
    stage('Dev Deployment') {
        when {
            expression {
                return env.GIT_BRANCH ==~ '.*/master'
            }
        } 
      steps {
        container('k8s') {
        sh '''
        set -e
        git config --global --add safe.directory $PWD
        commitId=$(git log -1 --format=%h)
        echo $commitId
        echo "$registryUrl/book-api:$commitId"
        kubectl set image deployment/book-api main=$registryUrl/book-api:$commitId -n default
        '''
        }
      }
    }
    stage('Prod Deployment') {
    when {
        expression {
            return env.GIT_BRANCH ==~ '^refs/tags/v(d+.d+.d+)'
        }
    } 
      steps {
        container('docker') {
        sh '''
        set -e
        git config --global --add safe.directory $PWD
        commitId=$(git log -1 --format=%h)
        echo $commitId
        echo "$registryUrl/book-api:$commitId"
        echo "Docker login"
        echo $registryPassword | docker login -u $registryUser $registryUrl --password-stdin
        docker pull $registryUrl/book-api:$commitId
        docker tag $registryUrl/book-api:$commitId $registryUrl/book-api:latest-release
        docker push $registryUrl/book-api:latest-release
        '''
        }
        container('k8s') {
        sh '''
        set -e
        git config --global --add safe.directory $PWD
        commitId=$(git log -1 --format=%h)
        echo $commitId
        echo "$registryUrl/book-api:$commitId"
        kubectl set image deployment/book-api main=$registryUrl/book-api:$commitId -n default
        '''
        }
      }
    }
  }
}
