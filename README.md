# quickstart-tibco-spotfire-data-science

## TIBCO Spotfire Data Science on the AWS Cloud

This Quick Start automatically deploys TIBCO Spotfire Data Science into a customizable environment on the Amazon Web Services (AWS) Cloud.

The Quick Start offers two deployment options:

- [Deploying TIBCO Spotfire Data Science into a new virtual private cloud (VPC) on AWS](templates/tibco-spotfire-data-science-master.yaml)
- [Deploying TIBCO Spotfire Data Science into an existing VPC on AWS](templates/tibco-spotfire-data-science.yaml)

You can also use the AWS CloudFormation templates as a starting point for your own implementation.

![Quick Start architecture for TIBCO Spotfire Data Science on AWS](https://s3.amazonaws.com/aws-cfn-samples/aws-quickstart/quickstart-tibco-spotfire-data-science/doc/TSDS-Architecture.png) 

### Deployment Steps
*_This Quick Start is currently in development. Step 3 below will be streamlined at the time of final publication_*

#### Step 1. Prepare Your AWS Account
1.	If you don’t already have an AWS account, create one at https://aws.amazon.com by following the on-screen instructions. 
2.	Use the region selector in the navigation bar to choose the AWS Region where you want to deploy TIBCO Data Science on AWS.
Important This Quick Start uses Amazon EFS, which is supported only in the regions listed on the AWS Regions and Endpoints webpage.
3.	Create a key pair in your preferred region. 
4.	If necessary, request a service limit increase for the Amazon EC2 M5.2xlarge instance type. You might need to do this if you already have an existing deployment that uses this instance type, and you think you might exceed the default limit with this deployment. 

#### Step 2. Subscribe to the TIBCO Data Science AMI
This Quick Start uses AWS Marketplace software from TIBCO and requires that you accept the terms within the AWS account where the Quick Start will be deployed.
1.	Log in to the AWS Marketplace at https://aws.amazon.com/marketplace.
2.	Open the page for the [TIBCO Data Science AMI](https://aws.amazon.com/marketplace/pp/B07KRRSWLY)
3.	Choose Continue to Subscribe.
4.	Choose Accept Software Terms. For detailed subscription instructions, see the [AWS Marketplace documentation](https://aws.amazon.com/marketplace/help/200799470).
 5.	When the subscription process is complete, exit out of AWS Marketplace without further action. Do not provision the software from AWS Marketplace—the Quick Start will deploy the AMI for you.

#### Step 3. Launch the Quick Start
See [Make the Quick Start your own](https://aws-quickstart.github.io/option1.html) section in the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/) on how to clone this GitHub repository, copy the code to your private S3 bucket and then launch the CloudFormation templates using your bucket.


---
To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.
If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/). 
