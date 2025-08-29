@Library('Shared') _

pipeline{
    agent any

    environment{
        DOCKER_IMAGE_NAME = 'suyashdahitule/easyshop-app'
        DOCKER_MIGRATION_IMAGE_NAME = 'suyashdahitule/easyshop-migration'
        IMAGE_TAG = "${BUILD_NUMBER}"
        GIT_CREDS = credentials('github_creds')
        GIT_URL = "https://github.com/suyash700/tws-e-commerce-app.git"
        GIT_BRANCH = "suyash1"
    }



    stages{
        stage("Clean Workspace"){
            steps{
              script{
                 cleanupWorkspace()
              }
            }
        }

        stage("pull repo(clone)"){
            steps{
                
                     git clone : "${GIT_URL}",branch :"${GIT_BRANCH}"
                
            }
        }

        stage("Build Docker Images"){
            parallel{
                stage("Build Docker-File"){
                    steps{
                        script{
                             docker_build(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'Dockerfile',
                                context: '.'
                            )
                        }
                    }
                }

                stage('Build Migration Image') {
                    steps {
                        script {
                            docker_build(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                dockerfile: 'scripts/Dockerfile.migration',
                                context: '.'
                            )
                        }
                    }
                }                
            }
        }


        stage("RUN TESTS"){
            steps{
                script{
                    run_tests()
                }
            }
        }

        stage('Security Scan with Trivy') {
            steps {
                script {

                    trivy_scan()
                    
                }
            }
        }        

        stage('Push Docker Images') {
            parallel {
                stage('Push Main App Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'dockerhub_creds'
                            )
                        }
                    }
                }
                
                stage('Push Migration Image') {
                    steps {
                        script {
                            docker_push(
                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,
                                imageTag: env.DOCKER_IMAGE_TAG,
                                credentials: 'dockerhub_creds'
                            )
                        }
                    }
                }
            }
        }

        stage("Update k8s manifests"){
            steps{
                script{
                    update_k8s_manifests(
                        imageTag: env.DOCKER_IMAGE_TAG,
                        manifestsPath: 'kubernetes',
                        gitCredentials: 'github_creds',
                        gitUserName: 'admin',
                        gitUserEmail: 'suyashdahitule12@gmail.com'
                    )
                }
            }
        }
  


    }
}
