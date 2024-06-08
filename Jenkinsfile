pipeline { 
     agent any 
     environment {  
        appImageName			= 'ibrahimadel10/flaskapp'               // dockerhub-repo-name/app-image-name
        dbImageName 			= 'ibrahimadel10/mysql'                 // dockerhub-repo-name/db-image-name
        dockerHubCredentialsID	= 'DockerHub'  		        // DockerHub credentials ID.
    }
    stages {

        stage('Build Images') {
            steps {      
            	 // Change to the directory where App Dockerfile 
            	 dir('docker/FlaskApp') {
                	sh "docker build -t ${appImageName}:${BUILD_NUMBER} ."	
                }
                // Change to the directory where DB Dockerfile 
            	 dir('docker/MySQL') {
                	sh "docker build -t ${dbImageName}:${BUILD_NUMBER} ."	
                }   
            }
        }

        stage('Push Images') { 
            steps {
            	withCredentials([usernamePassword(credentialsId: "${dockerHubCredentialsID}", usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
			sh "docker login -u ${USERNAME} -p ${PASSWORD}"
			sh "docker push ${appImageName}:${BUILD_NUMBER}"
                    	sh "docker push ${dbImageName}:${BUILD_NUMBER}" 
           	}
           }
        }

        stage('Remove Images') {
            steps {
                // delete images from jenkins server
                sh "docker rmi ${appImageName}:${BUILD_NUMBER}"
                sh "docker rmi ${dbImageName}:${BUILD_NUMBER}"
            }
        }

        stage('Deploy k8s Manifests') {
            steps {
            	 // Change to the directory where kubernetes manifist files
            	 dir('Kubernetes') {
                	// update images in deployment & statefulset manifists with new images
                	sh "sed -i 's|image:.*|image: ${appImageName}:${BUILD_NUMBER}|g' app-deployment.yaml"
                	sh "sed -i 's|image:.*|image: ${dbImageName}:${BUILD_NUMBER}|g' db-statefulset.yaml"
                    
                	//Deploy kubernetes manifists on EKS cluster
                		container('docker') {
            				script {
                				sh 'kubectl apply -f deployment.yaml'
            				}
        			}
            	 }
            }
        }
    }
}
        	       
    post {
        success {
            echo "${JOB_NAME}-${BUILD_NUMBER} pipeline succeeded"
        }
        failure {
            echo "${JOB_NAME}-${BUILD_NUMBER} pipeline failed"
        }
    }
}
