# infrastructure

&nbsp;

#### Pre requisites
##### 1. Install terraform in your system
> https://www.terraform.io/downloads.html

    Type terraform -v in your terminal to check terraform version
##### 2. Install Aws cli in your system
> https://aws.amazon.com/cli/

    Type aws --version in your terminal to check aws cli version


&nbsp;
#### Steps to run app using terraform infrastructure as code
##### 1. Clone git repository to your local system and navigate to the project in Terminal using cd infrastructure
##### 2. Type "terraform init"
##### 3. Type "terraform plan to check the deployment plan"

##### 4. Type "terraform apply to apply the changes to the cloud infrastructure"
&nbsp;



#### Command to import ssl certificate

aws acm import-certificate --certificate fileb://prod.chauhanankur.me.pem \
      --certificate-chain fileb://prod.chauhanankur.me.bundle.pem \
      --private-key fileb://privateKey.pem 	



