node {
    withEnv([
            'AWS_REGION=us-east-1',
            'AWS_ACCOUNT=851725482801'
    ]) {
        stage('Git: Checkout SCM') {
            checkout scm
        }

        stage('Docker: Clean Up Artifacts') {
            echo 'CLEANING...'
            sh 'docker system prune --all --volumes -f'
            sh 'docker builder prune --all -f'
        }

        def terraformDocker = null
        stage("Docker: Building Terraform Container") {
            terraformDocker = docker.build("terraform-docker")
        }

        terraformDocker.inside {
            stage("Terraform: Init & Workspace") {
                sh 'cd ./infra/terraform && terraform init -force-copy'
                sh "cd ./infra/terraform && terraform workspace select ${env.Environment} || terraform workspace new ${env.Environment}"
                sh 'cd ./infra/terraform && terraform workspace list'
            }

            stage("Terraform: Remove Orphaned State") {
                echo 'Remove orphans...'
            }

            stage("Terraform: Plan & Apply") {
                sh 'cd ./infra/terraform && terraform plan -out=tfplan'
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Complete deployment? Review the plan output above before approving.', ok: 'Deploy'
                }
                sh 'cd ./infra/terraform && terraform apply -auto-approve tfplan'
                sh 'cd ./infra/terraform && rm -f tfplan'
            }
        }

        stage('Docker: Clean Up Artifacts') {
            echo 'CLEANING...'
            sh 'docker system prune --all --volumes -f'
            sh 'docker builder prune --all -f'
        }
    }
}