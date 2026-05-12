import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

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
            stage("Terraform: Building AWS Infrastructure") {
                echo 'Deploying...'
                sh 'cd ./infra/terraform && terraform init -force-copy'
                sh 'cd ./infra/terraform && terraform workspace select ${Environment} || terraform workspace new ${Environment}'
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

            stage("Snowflake: Run Migrations") {
                def roleArn = sh(
                    script: 'cd ./infra/terraform && terraform output -raw snowflake_storage_role_arn',
                    returnStdout: true
                ).trim()
                def bucket = sh(
                    script: 'cd ./infra/terraform && terraform output -raw data_lake_bucket',
                    returnStdout: true
                ).trim()
                def database = "${env.Environment}_NMIS_ETL_PIPELINE"
                def integration = "${env.Environment}_S3_NMIS_ETL_DATA_LAKE_INTEGRATION"

                withCredentials([
                    file(credentialsId: 'snowflake-private-key',  variable: 'SF_PRIVATE_KEY_PATH'),
                    string(credentialsId: 'snowflake-account',     variable: 'SF_ACCOUNT'),
                ]) {
                    sh """
                        schemachange deploy \
                            --root-folder infra/snowflake/migrations \
                            --snowflake-account "\${SF_ACCOUNT}" \
                            --snowflake-user "JENKINS_AGENT" \
                            --snowflake-warehouse COMPUTE_WH \
                            --snowflake-database "${database}" \
                            --snowflake-private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --create-change-history-table \
                            --vars '{"role_arn": "${roleArn}", "bucket": "${bucket}", "database": "${database}", "integration": "${integration}"}'
                    """
                }
            }
        }

        stage('Docker: Clean Up Artifacts') {
            echo 'CLEANING...'
            sh 'docker system prune --all --volumes -f'
            sh 'docker builder prune --all -f'
        }

    }
}