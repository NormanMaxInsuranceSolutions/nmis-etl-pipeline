FROM amazon/aws-cli:latest

RUN yum install -y unzip zip python3 python3-pip && \
    pip3 install snowflake-cli schemachange && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "aarch64" ]; then \
        URL="https://releases.hashicorp.com/terraform/1.9.6/terraform_1.9.6_linux_arm64.zip"; \
    else \
        URL="https://releases.hashicorp.com/terraform/1.9.6/terraform_1.9.6_linux_amd64.zip"; \
    fi && \
    curl -sf "$URL" -o terraform.zip && \
    unzip -q terraform.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform.zip

WORKDIR /app

ENTRYPOINT []