pipeline {
  agent any
  stages {
    stage('ConnectRemote') {
      steps {
        sh '''#!/bin/bash
ping 192.168.1.18 -c 4 > /dev/null
if [ $? -eq 0 ] ;
then
        echo "Connection established"
else
        echo "No Connection"
fi'''
      }
    }

    stage('find_docker-images') {
      steps {
        sh '''#!/bin/bash
# https://www.youtube.com/watch?v=o9H303Z9ukc
REMOTE_USER="jenkins"
declare -a REMOTE_SERVERS=( "192.168.1.18" )
for target in "${REMOTE_SERVERS[@]}"
do
    echo "Connected to Server $target"
    ssh -T ${REMOTE_USER}@${target}<<-END
    docker images
    echo "----------------------------------------------------"
    docker ps
    echo "----------------------------------------------------"
    hostname -I
END
done'''
      }
    }

  }
}