#!/bin/bash
#
# Program: CodeDeploy install session helper on On-Premises
# Description: install session helper
if [ -e config.ini ]; then
  source config.ini
else
  echo "Can not find \'config.ini\'"
fi

helper_prefix="/opt/codedeploy-session-helper"

install_codedeploy_agent(){
  sudo apt-get install -y ruby wget
  wget https://aws-codedeploy-${Region}.s3.amazonaws.com/latest/install
  wait
  sudo chmod +x ./install
  sudo ./install auto
  wait
  rm install
}


install_session_helper(){
  if [ ! -d $helper_prefix ]; then
    sudo mkdir -p $helper_prefix
  fi

  sudo cp sts-renew config.ini $helper_prefix/
  sudo cp codedeploy-session-update /etc/cron.d/

  if [ ! -d $CodeDeploy_conf ]; then
    sudo mkdir -p $CodeDeploy_conf
  fi
  sudo tee ${CodeDeploy_conf}/${CodeDeploy_OnPremises_conf} <<EOF
---
iam_session_arn: $RoleSessionARN
aws_credentials_file: $CredentialsFile
region: $Region
EOF
  sudo chmod +x $helper_prefix/sts-renew
  sudo $helper_prefix/sts-renew
}

if [ -n awscli-setup ] && [ -n sts-renew ]; then
  sudo bash awscli-setup

  if [ ! -d ~/.aws ]; then
    sudo mkdir ~/.aws
  fi

  export Region=$Region

  tee ~/.aws/config <<EOF
[default]
region = $Region
output = json
EOF

  tee ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $ACCESS_KEY
aws_secret_access_key = $ACCESS_SECRET_KEY
EOF

  install_session_helper
  install_codedeploy_agent
else
  echo "Oops !! lost program ... please contact the system administrator"
fi
