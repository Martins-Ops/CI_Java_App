def gv
pipeline {
	agent any	
	tools {
        maven "MAVEN3"
        jdk "OracleJDK8"
    }

    environment {
        SNAP_REPO = 'java-snapshot'
        NEXUS_USER = 'admin'
        NEXUS_PASS = 'femi1234'
        RELEASE_REPO = 'java-release'
        CENTRAL_REPO = 'java-maven-central'
        NEXUSIP = '3.239.181.177'
        NEXUSPORT = '8081'
        NEXUS_GRP_REPO = 'java-maven-group'
        NEXUS_LOGIN = 'nexuslogin'
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
    }
    stages {
        stage('Build') {
            steps {
                dir('java-app'){
                    sh 'mvn -s ./settings.xml -DskipTests install'
                }        
            }
            // post {
            //     success {
            //         echo 'Now Archiving...'
            //         archiveArtifacts artifacts: '**/*.war'
            //     }
            // }
            post {
                always {
                    echo 'Slack Notifications'
                    slackSend channel: '#jenkins-cicd',
                        color: COLOR_MAP[currentBuild.currentResult],
                        message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
                }
            }
        }

        // stage('Test') {
        //     steps {
        //         dir('java-app'){
        //             sh 'mvn test'
        //         }
        //     }
        // }
        // stage('CODE ANALYSIS with Checkstyle Analysis') {
        //     steps {
        //         dir('java-app') {
        //             sh 'mvn -s settings.xml checkstyle:checkstyle'
        //         }
        //     }
        // }

        // stage('CODE ANALYSIS with SONARQUBE') {
        //     environment {
        //         scannerHome = tool "${SONARSCANNER}"
        //     }
        //     steps {
        //         dir('java-app') {
        //             withSonarQubeEnv("${SONARSERVER}") {
        //                 sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
        //                     -Dsonar.projectName=vprofile-repo \
        //                     -Dsonar.projectVersion=1.0 \
        //                     -Dsonar.sources=src/ \
        //                     -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
        //                     -Dsonar.junit.reportsPath=target/surefire-reports/ \
        //                     -Dsonar.jacoco.reportsPath=target/jacoco.exec \
        //                     -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
        //             }
        //         }
        //     }
        // }

        // stage('UPLOAD ARTIFACT') {
        //     steps {
        //         dir('java-app') { 
        //             nexusArtifactUploader(
        //                 nexusVersion: 'nexus3',
        //                 protocol: 'http',
        //                 nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
        //                 groupId: 'QA',
        //                 version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
        //                 repository: "${RELEASE_REPO}",
        //                 credentialsId: "${NEXUS_LOGIN}",
        //                 artifacts: [
        //                     [artifactId: 'javaapp' ,
        //                     classifier: '',
        //                     file: 'target/vprofile-v2.war',
        //                     type: 'war']
        //                 ]
        //             )
        //         }
        //     }
        // }

    }
}