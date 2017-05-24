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
              'copy'               : true,
	      'failFast'	   : false
            ]
            rtServer.promote promotionConfig
     }
}
