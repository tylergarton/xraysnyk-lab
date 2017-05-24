#!/usr/bin/env groovy

node ('master') {
    git url: GIT_URL
    def rtServer = Artifactory.newServer url: "http://jfrog.local/artifactory", credentialsId: CREDENTIALS
    def buildInfo = Artifactory.newBuildInfo()
    def tagDockerApp
    def rtDocker
    buildInfo.env.capture = true
   stage('Resolve') {
			               def downloadSpec = """{
 "files": [
  {
   "pattern": "jcenter-cache/junit/junit/3.8.1/junit-3.8.1.jar",
   "target": "./",
   "flat":"true"
  }
  ]
}"""
    println(downloadSpec)
        rtServer.download(downloadSpec, buildInfo)
	   }

    stage('deploy') {
       def uploadSpec = """{
  "files": [
    {
      "pattern": "junit*.*",
      "target": "libs-release-local/junit/junit/3.8.1/junit-3.8.1.jar"
    }
 ]
}"""
rtServer.upload(uploadSpec, buildInfo)
}
	   
    stage ('build & deploy') {
            tagDockerApp = "jfrog.local:5001/goofy:${env.BUILD_NUMBER}"
            docker.build(tagDockerApp)
            withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
                rtDocker = Artifactory.docker("${env.USERNAME}", "${env.PASSWORD}")
                rtDocker.push(tagDockerApp, 'docker-stage-local', buildInfo)
                rtServer.publishBuildInfo buildInfo
        }
     }

     stage('Xray Scan') {
             def xrayConfig = [
                'buildName'     : env.JOB_NAME,
                'buildNumber'   : env.BUILD_NUMBER,
                'failBuild'     : false
              ]
              def xrayResults = rtServer.xrayScan xrayConfig
              echo xrayResults as String
     }

     stage ('promotion') {
            def promotionConfig = [
              'buildName'          : env.JOB_NAME,
              'buildNumber'        : env.BUILD_NUMBER,
              'targetRepo'         : 'docker-prod-local',
              'comment'            : 'App works with latest released version of gradle swampup app, tomcat and jdk',
              'sourceRepo'         : 'docker-stage-local',
              'status'             : 'Released',
              'includeDependencies': false,
              'copy'               : true
            ]
            rtServer.promote promotionConfig
            reTagLatest (docker-prod-local)

     }
}


def reTagLatest (targetRepo) {
    def BUILD_NUMBER = env.BUILD_NUMBER
    sh 'sed -E "s/@/$BUILD_NUMBER/" retag.json > retag_out.json'
     switch (targetRepo) {
          case PROMOTE_REPO :
              sh 'sed -E "s/TARGETREPO/${PROMOTE_REPO}/" retag_out.json > retaga_out.json'
              break
          case SOURCE_REPO :
               sh 'sed -E "s/TARGETREPO/${SOURCE_REPO}/" retag_out.json > retaga_out.json'
               break
      }
    sh 'cat retaga_out.json'
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
        def curlString = "curl -u " + env.USERNAME + ":" + env.PASSWORD + " " + "http://jfrog.local/artifactory"
        def regTagStr = curlString +  "/api/docker/$targetRepo/v2/promote -X POST -H 'Content-Type: application/json' -T retaga_out.json"
        println "Curl String is " + regTagStr
        sh regTagStr
    }
}

def updateProperty (property) {
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS, usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
            def curlString = "curl -u " + env.USERNAME + ":" + env.PASSWORD + " " + "-X PUT " + SERVER_URL
            def updatePropStr = curlString +  "/api/storage/${SOURCE_REPO}/docker-app/${env.BUILD_NUMBER}?properties=${property}"
            println "Curl String is " + updatePropStr
            sh updatePropStr
     }
}