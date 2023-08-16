
# Continuous Integration Using jenkins, Nexus, Sonarqube and Slack

This project harnesses the power of Continuous Integration (CI) practices, Jenkins automation, Nexus repository management, SonarQube code analysis, and Slack notifications to enhance the development and deployment of a Java application.

![](/images/PROJECT-5.png )

## Pre-requisities:
- AWS Account 
- GitHub account
- Terraform
- Jenkins
- Nexus
- SonarQube
- Slack
- SSH Key

## Infrastructure Provisioning
The command below creates the following resources in the AWS console

- VPC
- Public Subnet 
- Internet Gateway
- Key Pair
- Security Group
- EC2 Instances

```bash
  cd tf-file
  terraform plan
  terraform apply -auto-approve
```

Upon succesful execution, the EC2 Instances makes usage of the Bash Scripts **./jenkins.sh** , **./nexus.sh** & **./sonarqube.sh** as *user_data* to install __Jenkins, Nexus and SonarQube__

## Post Installation Steps
For Jenkins Server:

- We need to SSH our jenkins server and check system status for Jenkins. Then we will get initialAdmin password from directory.

```bash
ssh -i <location_of_ssh-public-key> ubuntu@<public_ip_of_jenkins_server>
sudo -i
system status jenkins
cat /var/lib/jenkins/secrets/initialAdminPassword 
```
- Go to browser, http://<public_ip_of_jenkins_server>:8080, enter initialAdminPasswrd. We will also install suggested plugins. Then we will create our first admin user.
- We will install below plugins for Jenkins.
```bash
Maven Integration
Github Integration
Nexus Artifact Uploader
SonarQube Scanner
Slack Notification
Build Timestamp 
```
For Nexus Server:

- We need to SSH our nexus server and check system status for nexus.
```bash
ssh -i <location_of_ssh-public-key> ubuntu@<public_ip_of_nexus_server>
sudo -i
system status nexus
cat /opt/nexus/sonatype-work/nexus3/admin.password 
```
- Username is _admin_, paste password from previous step. Then we need to setup our new password and select _Disable Anonymous Access_

- We select gear symbol and create repository. This repo will be used to store our release artifacts.
```bash
maven2 hosted
Name: vprofile-release
Version policy: Release
```
- Next we will create a maven2 proxy repository. Maven will store the dependecies in this repository, whenever we need any dependency for our project it will check this proxy repo in Nexus first and download it for project. Proxy repo will download the dependecies from maven2 central repo at first.
```bash
maven2 proxy
Name: vpro-maven-central
remote storage: https://repo1.maven.org/maven2/
```

- This repo will be used to store our snapshot artifacts. That means any artifact with -SNAPSHOT extension will be stored in this repository.
```bash
maven2 hosted
Name: vprofile-snapshot
Version policy: Snapshot
```
- Last repo, will be maven2 group type. We will use this repo to group all maven repositories.
```bash
maven2 group
Name: vpro-maven-group
Member repositories: 
 - vpro-maven-central
 - vprofile-release
 - vprofile-snapshot
```

![](/images/nexus-repo.JPG )

For SonarQube Server:

- Go to browser, http://<public_ip_of_sonar_server>.

- Login with username admin and password admin.


## Build Job with Nexus Repo

- Our first job will be Build the Artifact from Source Code using Maven. We need JDK8 and Maven to be installed in jenkins to complete the job succesfully.

- Since our application is using JDK8, we need to install Java8 in jenkins. Manage Jenkins -> Global Tool Configuration We will install JDK8 manually, and specify its PATH in here.
```bash
Under JDK -> Add JDK
Name: OracleJDK8
untick Install Automatically
JAVA_HOME: /usr/lib/jvm/java-8-openjdk-amd64
```
- Currently our jenkins has JDK-11 install, we can SSH into our jenkins server and install JDK-8. Then get the PATH to JDK-8 to replace in above step. So after installation we will see our `JAVA_HOME` for JDK-8 is /usr/lib/jvm/java-8-openjdk-amd64
```bash
sudo apt update -y
sudo apt install openjdk-8-jdk -y
```
- Next we will setup our Maven.
```bash
Name: MAVEN3
version : keep same
```
- Next we need to add Nexus login credentials to Jenkins. Go to Manage Jenkins -> Manage Credentials -> Global -> Add Credentials
```bash
username: admin
password: <pwd_setup_for_nexus>
ID: nexuslogin
description: nexuslogin
```
- We will create a New Job in Jenkins with below properties:
```bash
Pipeline from SCM 
Git
URL: <ssh_url_from_project> 
Crdentials: we will create github login credentials
#### add Jenkins credentials for github ####
Kind: SSH Username with private key
ID: githublogin
Description: githublogin
Username: git
Private key file: paste your private key here
#####
Branch: */main
path: Jenkinsfile
```

##  Code Analysis with SonarQube
 - The Unit test/Code Coverage reports are generated under Jenkins workspace target directory. But these reports are not human readable. We need a tool which can scan and analyze the coed and present it in human readable format in a Dashboard. We will use SonarQube solution of this problem. Two things need to setup:
- SonarScanner tool in Jenkins to scan the code
- We need SonarQube information in jenkins so that Jenkins will know where to upload these reports
- Lets start with SonarScanner tool configuration. Go to Manage Jenkins -> Global Tool Configuration
```bash
Add sonarqube scanner
name: Sonarscanner
tick install automatically
```
- Next we need to go to Configure System, and find  SonarQube servers section
```bash
tick environment variables
Add sonarqube
Name: sonarserver
Server URL: http://<private_ip_of_sonar_server>
Server authentication token: we need to create token from sonar website
```
![](/images/sonartoken.png)

- We will add our sonar token to global credentials.

```bash
Kind: secret text
Secret: <paste_token>
name: sonartoken
description: sonartoken
```
- Our job is completed succesfully.

![](/images/4Build.JPG)

![](/images/nrepo.JPG)

- Next we will create a Webhook in SonarQube to send the analysis results to jenkins. http://<private_ip_of_jenkins>:8080/sonarqube-webhook

- This can be done in the project settings -> webhook

![](/images/sq.JPG)

## Slack Notification

- We will Login to slack and create a workspace by following the prompts. Then we will create a channel jenkins-cicd in our workspace.

- Next we need to Add jenkins app to slack. Search in Google with Slack apps. Then search for jenkins add to Slack. We will choose the channel jenkins-cicd. It will give us to setup instructions, from there copy Integration token credential ID.

- We will go to Jenkins dashboard Configure system -> Slack
```bash
Workspace: example (in the workspace url example.slack.com)
credential: slacktoken 
default channel: #jenkins-cicd
We will add our slack token to global credentials.
Kind: secret text
Secret: <paste_token>
name: slacktoken
description: slacktoken
```
- We will add below part to our Jenkinsfile in the same level with stages and push our changes.
```bash
post{
        always {
            echo 'Slack Notifications'
            slackSend channel: '#jenkinscicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
    }
```
- Run Build again on Jenkins UI

![](/images/slack2.JPG)
