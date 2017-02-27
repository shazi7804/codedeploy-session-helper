# codedeploy-session-helper

The codedeploy-session-helper can help you build codedeploy onpremises automatically generate `sts:AssumeRole` session

## Install

    $ chmod +x install.sh
    $ sudo ./install.sh

## Config

- Region = AWS region
- ACCESS_KEY = IAM User access key (need sts:AssumeRole with Role)
- ACCESS_SECRET_KEY = same ACCESS_KEY
- RoleARN = Role ARN by On Premises (need S3 permissions)
- RoleSessionARN = `sts:AssumeRole` session
