
#!/bin/bash
#tfsec checkov
set -x
pip install wget

export TF_LOG="DEBUG"
export TF_LOG_PATH="./terraform.log"

ENV=dev
TF_PATH=${ENV}.tfplan

# URL="https://github.com/tfsec/tfsec/releases/download/v1.28.1/tfsec-darwin-amd64"

# echo $(date) 'Running wget...'
# wget   ${URL}
 
# chmod +x tfsec-darwin-amd64
# mv  tfsec-darwin-amd64 /usr/local/bin/tfsec


[ -d .terraform ] && rm -rf .terraform
rm -f *.tfplan
sleep 2

terraform fmt -recursive
terraform init
terraform validate
terraform plan -out ${TF_PATH}
#tfsec .
terraform show -json ${TF_PATH}  > ${TF_PATH}.json
checkov -f ${TF_PATH}.json

if [ $? -eq 0  ]
then
    echo "your configuration is valid"
else
    echo "your code is not working"
	  exit 1
fi

terraform plan -out ${TF_PATH}

# if [ ! -f ${TF_PATH}  ]
# then 
#     echo "The plan does not exit, Exiting"
# 	  exit 1
# fi




