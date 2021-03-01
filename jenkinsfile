pipeline {
	environment {
   		 DOCKER_REPO = "dtr.nagarro.com:443/ankitakumari-i"
   		 CONTAINER_NAME = 'ankitakumari-c'
	//	 KUBECONFIG = '/Users/ankitakumari/.kube/config'
	}
    agent any
    tools { 
        maven 'Maven3' 
        jdk 'JDK' 
    }
	
    stages {
    	stage('clean') { 
    		steps {
    			deleteDir()
			}
		}
    
		stage('Checkout') {
			steps {
				checkout scm
			}
		}
    	
		stage ('Build and Unit Testing') {
			steps {
				bat 'mvn clean install -Dmaven.test.failure.ignore=true' 
			}
			post {
				success {
					junit 'target/surefire-reports/**/*.xml' 
				}
			}
		}
			
		stage("Sonar Analysis") {
				agent any
				steps {
					withSonarQubeEnv('Test_Sonar') {
					bat 'mvn clean package sonar:sonar'
				}
			}
		}
		
		stage ('Upload to Artifactory') {
			steps {
				rtUpload (
					serverId: '123456789@artifactory', 
					spec: """{
							"files": [
									{
										"pattern": "**/*.war",
										"target": "nagp_demo_snapshot"
									}
								]
					}"""
				)
			}
		}
				
		stage ('Docker Image') {
			steps {
			bat 'docker build -t %DOCKER_REPO%:%BUILD_NUMBER% -f Dockerfile .' 
			}
		}
				
		stage ('Push to DTR') {
				steps {
					bat 'docker push %DOCKER_REPO%:%BUILD_NUMBER%'
			}
		}
				
		stage ('Stop Running Containers') {
				steps {
				   bat '''
			    FOR /F "tokens=* USEBACKQ" %%F IN (`docker ps -aqf "name=^%CONTAINER_NAME%"`) DO (
							SET ContainerID=%%F
				)
				
						
				IF [%ContainerID%] EQU []  (
				   ECHO "Docker container with name %CONTAINER_NAME% does not exists. Creating container..."
				) ELSE (
				    ECHO "Docker container with name %CONTAINER_NAME% already exists. Removing container..."
					docker stop %ContainerID%
					docker rm %ContainerID%
				)
			  
			 '''
			}
		}
			
		stage ('Docker Deployment') {
				steps {
				   bat '''
				   docker run --name %CONTAINER_NAME% -d -p 6200:8080 %DOCKER_REPO%:%BUILD_NUMBER%
			        '''
			    }
		}
    
    }
}
