
pipeline {
    agent any

    triggers {
        pollSCM('H/5 * * * *')
    }

    environment {
        AWS_REGION = 'ap-south-2'
        AWS_ACCOUNT_ID = '595236027539'
        ECR_REGISTRY = '595236027539.dkr.ecr.ap-south-2.amazonaws.com'
        COMPOSE_PROJECT_NAME = 'microservice-ecom-docker-compose'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/m-dhineshkumar25/microservice-ecom-docker-compose.git'
            }
        }

        stage('Validate') {
            steps {
                sh '''
                    set -e
                    test -f user-service/Dockerfile
                    test -f product-service/Dockerfile
                    test -f order-service/Dockerfile
                    docker compose -f docker-compose.deploy.yml config --quiet
                    echo "Validation successful"
                '''
            }
        }

        stage('Build and Push to ECR') {
            steps {
                sh '''
                    set -e
                    IMAGE_TAG="build-${BUILD_NUMBER}"

                    aws ecr get-login-password --region "$AWS_REGION" |
                        docker login --username AWS --password-stdin "$ECR_REGISTRY"

                    for SERVICE in user-service product-service order-service; do
                        docker build -t "$SERVICE:$IMAGE_TAG" "./$SERVICE"
                        docker tag "$SERVICE:$IMAGE_TAG" "$ECR_REGISTRY/$SERVICE:$IMAGE_TAG"
                        docker push "$ECR_REGISTRY/$SERVICE:$IMAGE_TAG"
                    done

                    echo "$IMAGE_TAG" > image-tag.txt
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -e
                    IMAGE_TAG=$(cat image-tag.txt)
                    export IMAGE_TAG

                    docker compose -p "$COMPOSE_PROJECT_NAME" \
                        -f docker-compose.deploy.yml pull

                    docker compose -p "$COMPOSE_PROJECT_NAME" \
                        -f docker-compose.deploy.yml up -d
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    set -e

                    for SERVICE in user-service product-service order-service; do
                        for i in $(seq 1 12); do
                            STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$SERVICE")

                            if [ "$STATUS" = "healthy" ]; then
                                echo "$SERVICE: healthy"
                                break
                            fi

                            if [ "$i" -eq 12 ]; then
                                echo "$SERVICE failed health check"
                                exit 1
                            fi

                            sleep 5
                        done
                    done

                    for PATH_NAME in user products orders; do
                        curl -fsS "http://localhost/$PATH_NAME/" > /dev/null
                        echo "$PATH_NAME route: OK"
                    done
                '''
            }
        }
    }

    post {
        success {
            echo 'Microservices build and deployment completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs before retrying.'
        }
    }
}

