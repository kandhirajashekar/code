pipeline {
  agent any
  tools {
  
  maven 'maven'
   
  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://For_demo@bitbucket.org/For_demo/java.git']]])
        }
      }
	  
	  stage ('Build')  {
	      steps {
          
            //dir('java-source'){
            sh "mvn package"
          }
        }
         
   
     stage ('SonarQube Analysis') {
        steps {
              withSonarQubeEnv('sonar') {
                
				//dir('java-source'){
                 sh 'mvn -U clean install sonar:sonar'
                }
				
              }
            }

    stage ('Artifactory configuration') {
            steps {
                sh 'mvn -s settings.xml deploy'
                
            }
    }


    stage('Copy Dockerfile & Playbook to Ansible Server') {
            
            steps {
                  sshagent(['SSH_key']) {
                       
                        sh "scp -o StrictHostKeyChecking=no Dockerfile ec2-user@172.31.4.233:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@172.31.4.233:/home/ec2-user"
                    }
                }
            
        } 
    stage('Build Container Image') {
            
            steps {
                  sshagent(['SSH_key']) {
                        echo "${env.BUILD_NUMBER}"
                              println "${env.BUILD_NUMBER}"
                              sh "ssh -o StrictHostKeyChecking=no ec2-user@172.31.4.233 -C \"sudo ansible-playbook create-container-image.yaml -e Build_Number=${env.BUILD_NUMBER}\""
                        
                    }
                }
            
        } 
    stage('Copy Definition files to K8s Master') {
            
            steps {
                  sh "chmod +x ChangeTag.sh"
                  sh "./ChangeTag.sh ${env.BUILD_NUMBER}"
                  sshagent(['SSH_key']) {
                       
                        sh "scp -o StrictHostKeyChecking=no K8s-deployement.yaml ubuntu@172.31.27.234:/home/ubuntu"
                        sh "scp -o StrictHostKeyChecking=no nodeport.yaml ubuntu@172.31.27.234:/home/ubuntu"
                    }
                }
            
        }

    stage('Waiting for Approvals') {
            
        steps{

				input('Test Completed ? Please provide  Approvals for Prod Release ?')
			  }
            
    }     
    stage('Deploy Production') {
            
            steps {
                  sshagent(['SSH_key']) {
                       script{
                          try{
                               sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.27.234 -C \"sudo kubectl apply -f . --validate=false\""
                          }catch(error){
                               sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.27.234 -C \"sudo kubectl create -f . --validate=false\""
                        
                    }
                }
            }
         } 
      }     
    }
}