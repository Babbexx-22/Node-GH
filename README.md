## CICD USING GITHUB ACTIONS (FOR A NODE JS APPLICATION)

In the previous project, [AWS-CICD-Pipeline-Project](https://github.com/Babbexx-22/AWS-CICD-Pipeline-Project/tree/main), Continuous integration was carried out using AWS code commit as the version control system while AWS code build was used for continuous integration. Here, we shall employ the use of github and github actions accordingly.

----------------------------------------
**LATER EXPLORATION**: "OPENID Connect". This allows GitHub Actions workflows to access resources in Amazon Web Services (AWS), without needing to store the AWS credentials as long-lived GitHub secrets.
RESOURCES: [OIDC WITH AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)
----------------------------------------

## PREREQUISITES

- GitHub Account: You need a GitHub account to create and manage repositories.

- Local Development Environment

- Git: Install Git on your development machine.

- GitHub Actions Enabled: Enable GitHub Actions for the repository. This can be done by going to the repository on GitHub, clicking on the "Actions" tab, and following the prompts to enable Actions.

- Access Tokens or Secrets (if required): Depending on your CI/CD workflow and the services you use, you may need to set up access tokens or secrets to authenticate with external services. For example, if you need to deploy to a cloud provider, you may need to set up access tokens for authentication. Ensure you have the necessary credentials or tokens ready.

- Set up an IAM user with the necessary permissions. In this project, I already have a user preconfigured with administrative full access.

------------------------------------------------------------------

## STEPS INVOLVED

- Clone the repository to be used and sync it with your local environment.
- Review your source code
- Create a workflow file to define the CI/CD pipeline.
- Inside the repository, create a new directory ".github/workflows".
- Create a new YAML file inside the ".github/workflows" directory.
------------------------------------------------------------------

![tree](https://github.com/Babbexx-22/Node-GH/assets/114196715/aee798bb-dcad-43db-bf94-98b7417909b3)
------------------------------------------------------------------

- Open the yaml file and define the workflow using the GitHub Actions syntax.
- Specify the triggers, such as push and required event filters, to indicate when the workflow should run. The workflow file was defined to run upon any push event to the master branch.
  For certain instances during the configuration wherein a push event was done and a workflow trigger wasnt intended, `[no ci]` was added to the commit message to prevent the trigger of the workflow.

------------------------------------------------------------------

![SKIP CI](https://github.com/Babbexx-22/Node-GH/assets/114196715/4ff426a8-2149-45c1-a29f-cd2ec636fe61)

------------------------------------------------------------------

- Define the jobs, steps, and actions required for building, testing, and deploying the application.
- Create a private repository in AWS to accomodate the docker image to be pushed.
  
##  A WALKTHROUGH OF THE WORKFLOW FILE

- Environmental variables and secrets were configured for use in the workflow file. This allows us to reference repeated snippets and define sensitive or private information (such as credentials) respectively.

![ENV](https://github.com/Babbexx-22/Node-GH/assets/114196715/7abeb6c2-4a28-4fbd-a6f1-b9b22a0dcacb)
![SECRETS](https://github.com/Babbexx-22/Node-GH/assets/114196715/f4c1f8be-02ef-455a-8fa4-d1563dd91626)

------------------------------------------------------------------

The workflow file had three jobs defined; "setup", "build" and "push" in order to work around different job runners and how to make the build result of one job available for use in another.

- **SETUP**: node js was installed on the runner server. This finds use when there is need to use a particular version of node for your work environment which differs from that preinstalled on all runner servers.

```
setup:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout 
      uses: actions/checkout@v3
    - name: setup node js app on github runner
      uses: actions/setup-node@v3
      with:
        node-version: 18
    - name: install node js dependencies  
      run: npm ci
```

- **BUILD**: The docker image was built and tagged and the resulting build image was uploaded as an artifact for use in subsequent job.

```
build:
    needs: setup
    runs-on: ubuntu-latest

    steps:
    - name: checkout
      uses: actions/checkout@v3
    
    - name: build and tag image
      run: |
        docker build -t my-app .
        docker tag my-app ${{ secrets.AWS_REGISTRY_URL }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}
    
    - name: Upload image
      uses: ishworkh/docker-image-artifact-upload@v2.0.1
      with:
        image: ${{ secrets.AWS_REGISTRY_URL }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}
```

- **PUSH**: The image was downloaded using the appropriate action, the AWS credentials was configured and amazon ecr was logged unto and the image was pushed to amazon ecr.

```
push:
    needs: build
    runs-on: ubuntu-latest
    outputs:
      output_name: ${{ steps.login-ecr.outputs.registry }}
    
    steps:
    - name: checkout
      uses: actions/checkout@v3
    
    - name: Download an image
      uses: ishworkh/container-image-artifact-download@v1.0.0
      with:
        image: ${{ secrets.AWS_REGISTRY_URL }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}
    
    
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}
    
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
    
    - name: push docker image to Amazon ECR
      run: docker push ${{ secrets.AWS_REGISTRY_URL }}/${{ env.ECR_REPOSITORY }}:${{ env.IMAGE_TAG }}

```

![PIPE 1](https://github.com/Babbexx-22/Node-GH/assets/114196715/50dbd914-84f1-4bb8-b3dd-8713fbbe702b)

![PIPE 2](https://github.com/Babbexx-22/Node-GH/assets/114196715/2e44bb02-66d8-44cc-ad09-ffee15957bed)

![PIPE 3](https://github.com/Babbexx-22/Node-GH/assets/114196715/d31ff817-d949-4464-a7bf-20558a66e20d)

![PIPE 4](https://github.com/Babbexx-22/Node-GH/assets/114196715/de5a1b82-e95e-4147-b6ab-a322a0193efb)
