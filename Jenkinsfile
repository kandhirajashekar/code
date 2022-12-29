pipeline {
  agent any
  tools {
  
  maven 'maven'
   
  }
    stages {

      stage ('Checkout SCM'){
        steps {
          checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git_cred', url: 'https://saidevopstraining-admin@bitbucket.org/saidevopstraining/jenkins-pipeline.git']]])
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
                  sshagent(['ssh_cred']) {
                       
                        sh "scp -o StrictHostKeyChecking=no Dockerfile ec2-user@10.1.1.123:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no create-container-image.yaml ec2-user@10.1.1.123:/home/ec2-user"
                    }
                }
            
        } 
    stage('Build Container Image') {
            
            steps {
                  sshagent(['ssh_cred']) {
                        echo "${env.BUILD_NUMBER}"
                              println "${env.BUILD_NUMBER}"
                              sh "ssh -o StrictHostKeyChecking=no ec2-user@10.1.1.123 -C \"sudo ansible-playbook create-container-image.yaml -e Build_Number=${env.BUILD_NUMBER}\""
                        
                    }
                }
            
        } 
    stage('Copy Definition files to K8s Master') {
            
            steps {
                  sh "chmod +x ChangeTag.sh"
                  sh "./ChangeTag.sh ${env.BUILD_NUMBER}"
                  sshagent(['ssh_cred']) {
                       
                        sh "scp -o StrictHostKeyChecking=no K8s-deployement.yaml ubuntu@10.1.1.219:/home/ubuntu"
                        sh "scp -o StrictHostKeyChecking=no nodeport.yaml ubuntu@10.1.1.219:/home/ubuntu"
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
                  sshagent(['ssh_cred']) {
                       script{
                          try{
                               sh "ssh -o StrictHostKeyChecking=no ubuntu@10.1.1.219 -C \"sudo kubectl apply -f . --validate=false\""
                          }catch(error){
                               sh "ssh -o StrictHostKeyChecking=no ubuntu@10.1.1.219 -C \"sudo kubectl create -f . --validate=false\""
                        
                    }
                }
            }
         } 
      }     
    }
}