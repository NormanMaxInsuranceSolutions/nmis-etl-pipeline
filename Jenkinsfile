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
            def database    = "${env.Environment}_NMIS_ETL_PIPELINE"
            def integration = "${env.Environment}_S3_NMIS_ETL_DATA_LAKE_INTEGRATION"
            def ssmPrefix   = "/NMIS/${env.Environment.toUpperCase()}/ETL_PIPELINES"

            // roleArn and bucket are captured after Phase 1 apply and reused throughout
            def roleArn = null
            def bucket  = null

            stage("Terraform: Init & Workspace") {
                sh 'cd ./infra/terraform && terraform init -force-copy'
                sh "cd ./infra/terraform && terraform workspace select ${env.Environment} || terraform workspace new ${env.Environment}"
                sh 'cd ./infra/terraform && terraform workspace list'
            }

            stage("Terraform: Remove Orphaned State") {
                echo 'Remove orphans...'
            }

            // Pre-populate placeholder SSM params so Terraform can resolve all data sources
            // on a fresh environment. Uses put-parameter without --overwrite so real values
            // from a previous run are preserved (the command fails silently if the param exists).
            stage("SSM: Bootstrap Placeholder Params") {
                sh """
                    aws ssm put-parameter \
                        --name '${ssmPrefix}/SNOWFLAKE_IAM_USER_ARN' \
                        --value 'arn:aws:iam::000000000000:user/placeholder' \
                        --type String || true

                    aws ssm put-parameter \
                        --name '${ssmPrefix}/SNOWFLAKE_STORAGE_EXTERNAL_ID' \
                        --value 'placeholder' \
                        --type String || true
                """
            }

            // ─── Terraform Phase 1 ──────────────────────────────────────────────────
            // Apply everything except aws_s3_bucket_notification.etl_snowpipes, which
            // requires the Snowpipe SQS ARN — a value Snowflake only generates after the
            // pipe is created in schemachange Phase 2.
            stage("Terraform: Plan Phase 1") {
                sh """
                    cd ./infra/terraform && terraform plan -out=tfplan \
                        -target=aws_s3_bucket.data_lake \
                        -target=aws_s3_bucket_versioning.data_lake \
                        -target=aws_s3_bucket_server_side_encryption_configuration.data_lake \
                        -target=aws_s3_bucket_public_access_block.data_lake \
                        -target=aws_s3_bucket_policy.data_lake_appflow \
                        -target=aws_iam_role.snowflake_storage \
                        -target=aws_iam_policy.snowflake_storage \
                        -target=aws_iam_role_policy_attachment.snowflake_storage \
                        -target=module.salesforce_connector \
                        -target=module.salesforce_policy_to_s3 \
                        -target=aws_ssm_parameter.data_lake_bucket \
                        -target=aws_ssm_parameter.salesforce_secret_arn
                """
            }

            stage("Terraform: Apply Phase 1") {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Complete Phase 1 deployment? Review the plan output above before approving.', ok: 'Deploy'
                }
                sh 'cd ./infra/terraform && terraform apply -auto-approve tfplan && rm -f tfplan'
                roleArn = sh(script: 'cd ./infra/terraform && terraform output -raw snowflake_storage_role_arn', returnStdout: true).trim()
                bucket  = sh(script: 'cd ./infra/terraform && terraform output -raw data_lake_bucket', returnStdout: true).trim()
            }

            // ─── Schemachange Phase 1 (V1.0.0 – V1.1.0) ────────────────────────────
            // Creates the POLICY table and the Snowflake storage integration.
            // After V1.1.0, Snowflake generates the IAM user ARN and external ID that
            // the IAM role trust policy needs — capture them and write to SSM.
            stage("Snowflake: Migrations Phase 1 (V1.0.0-V1.1.0)") {
                withCredentials([
                    file(credentialsId: 'snowflake-private-key',  variable: 'SF_PRIVATE_KEY_PATH'),
                    string(credentialsId: 'snowflake-account',     variable: 'SF_ACCOUNT'),
                ]) {
                    sh """
                        schemachange deploy \
                            --root-folder infra/snowflake/migrations \
                            --snowflake-account "\${SF_ACCOUNT}" \
                            --snowflake-user JENKINS_AGENT \
                            --snowflake-warehouse COMPUTE_WH \
                            --snowflake-database "${database}" \
                            --snowflake-private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --create-change-history-table \
                            --target-version 1.1.0 \
                            --vars '{"role_arn":"${roleArn}","bucket":"${bucket}","database":"${database}","integration":"${integration}"}'
                    """

                    sh """
                        snow sql \
                            --query "DESC INTEGRATION ${integration}" \
                            --account "\${SF_ACCOUNT}" \
                            --user JENKINS_AGENT \
                            --private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --format json > /tmp/sf_integration.json
                    """

                    sh '''
                        python3 -c "
import json
rows = json.load(open('/tmp/sf_integration.json'))
props = {r['property']: r['property_value'] for r in rows}
open('/tmp/sf_iam_user_arn.txt', 'w').write(props['STORAGE_AWS_IAM_USER_ARN'])
open('/tmp/sf_external_id.txt', 'w').write(props['STORAGE_AWS_EXTERNAL_ID'])
"
                    '''

                    def iamUserArn = sh(script: "cat /tmp/sf_iam_user_arn.txt", returnStdout: true).trim()
                    def externalId  = sh(script: "cat /tmp/sf_external_id.txt",  returnStdout: true).trim()

                    sh """
                        aws ssm put-parameter \
                            --name '${ssmPrefix}/SNOWFLAKE_IAM_USER_ARN' \
                            --value '${iamUserArn}' \
                            --type String --overwrite

                        aws ssm put-parameter \
                            --name '${ssmPrefix}/SNOWFLAKE_STORAGE_EXTERNAL_ID' \
                            --value '${externalId}' \
                            --type String --overwrite
                    """
                }
            }

            // ─── Terraform Phase 2 ──────────────────────────────────────────────────
            // Targeted apply — updates the IAM role trust policy with the real Snowflake
            // IAM user ARN now in SSM. Auto-approved: narrowly scoped, non-destructive.
            stage("Terraform: Plan & Apply Phase 2 (IAM Trust Update)") {
                sh """
                    cd ./infra/terraform && terraform plan -out=tfplan \
                        -target=aws_iam_role.snowflake_storage \
                        -target=aws_iam_policy.snowflake_storage \
                        -target=aws_iam_role_policy_attachment.snowflake_storage
                """
                sh 'cd ./infra/terraform && terraform apply -auto-approve tfplan && rm -f tfplan'
            }

            // ─── Schemachange Phase 2 (V1.2.0 – V1.3.0) ────────────────────────────
            // Creates the external S3 stage (now that the IAM trust is correct) and the
            // Snowpipe. After V1.3.0, Snowflake generates the SQS notification_channel
            // ARN — capture it and write to SSM for the final Terraform apply.
            stage("Snowflake: Migrations Phase 2 (V1.2.0-V1.3.0)") {
                withCredentials([
                    file(credentialsId: 'snowflake-private-key',  variable: 'SF_PRIVATE_KEY_PATH'),
                    string(credentialsId: 'snowflake-account',     variable: 'SF_ACCOUNT'),
                ]) {
                    sh """
                        schemachange deploy \
                            --root-folder infra/snowflake/migrations \
                            --snowflake-account "\${SF_ACCOUNT}" \
                            --snowflake-user JENKINS_AGENT \
                            --snowflake-warehouse COMPUTE_WH \
                            --snowflake-database "${database}" \
                            --snowflake-private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --target-version 1.3.0 \
                            --vars '{"role_arn":"${roleArn}","bucket":"${bucket}","database":"${database}","integration":"${integration}"}'
                    """

                    sh """
                        snow sql \
                            --query "SHOW PIPES IN SCHEMA ${database}.SALESFORCE" \
                            --account "\${SF_ACCOUNT}" \
                            --user JENKINS_AGENT \
                            --private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --format json > /tmp/sf_pipes.json
                    """

                    sh '''
                        python3 -c "
import json
rows = json.load(open('/tmp/sf_pipes.json'))
pipe = next(p for p in rows if p['name'].upper() == 'POLICY_PIPE')
open('/tmp/sf_sqs_arn.txt', 'w').write(pipe['notification_channel'])
"
                    '''

                    def sqsArn = sh(script: "cat /tmp/sf_sqs_arn.txt", returnStdout: true).trim()

                    sh """
                        aws ssm put-parameter \
                            --name '${ssmPrefix}/SNOWPIPE_SQS_ARN' \
                            --value '${sqsArn}' \
                            --type String --overwrite
                    """
                }
            }

            // ─── Terraform Phase 3 ──────────────────────────────────────────────────
            // Full apply — all three SSM params are now populated with real values.
            // Creates aws_s3_bucket_notification.etl_snowpipes pointing to the Snowpipe SQS queue.
            stage("Terraform: Plan Phase 3 (Full)") {
                sh 'cd ./infra/terraform && terraform plan -out=tfplan'
            }

            stage("Terraform: Apply Phase 3 (Full)") {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Complete Phase 3 deployment? Review the plan output above before approving.', ok: 'Deploy'
                }
                sh 'cd ./infra/terraform && terraform apply -auto-approve tfplan && rm -f tfplan'
            }

            // ─── Schemachange Phase 3 (V1.4.0) ──────────────────────────────────────
            // Creates the stream and scheduled merge task. schemachange only applies
            // migrations not yet in the CHANGE_HISTORY table, so this picks up exactly
            // where Phase 2 left off.
            stage("Snowflake: Migrations Phase 3 (V1.4.0)") {
                withCredentials([
                    file(credentialsId: 'snowflake-private-key',  variable: 'SF_PRIVATE_KEY_PATH'),
                    string(credentialsId: 'snowflake-account',     variable: 'SF_ACCOUNT'),
                ]) {
                    sh """
                        schemachange deploy \
                            --root-folder infra/snowflake/migrations \
                            --snowflake-account "\${SF_ACCOUNT}" \
                            --snowflake-user JENKINS_AGENT \
                            --snowflake-warehouse COMPUTE_WH \
                            --snowflake-database "${database}" \
                            --snowflake-private-key-path "\${SF_PRIVATE_KEY_PATH}" \
                            --vars '{"role_arn":"${roleArn}","bucket":"${bucket}","database":"${database}","integration":"${integration}"}'
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