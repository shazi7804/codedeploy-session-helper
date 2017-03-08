#!/bin/bash
#
# Program: CodeDeploy install session helper on On-Premises
# Description: install session helper
if [ -e config.ini ]; then
  source config.ini
else
  echo "Can not find \'config.ini\'"
fi

install_session_helper(){
  # install sts-renew
  if [ ! -d $helper_prefix ]; then
    sudo mkdir -p $helper_prefix
  fi
  sudo cp sts-renew $helper_prefix/
  sudo tee $helper_prefix/sts-renew.ini <<EOF
RoleARN=$RoleARN
RoleSession=$RoleSession
CredentialsFile=$CredentialsFile
EOF

  # Run sts-renew every 30 minutes
  sudo cp codedeploy-session-update /etc/cron.d/

  # setting codedeploy agent for onpremises
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

if [ -n awscli-setup ] && [ -n sts-renew ] && [ -n codedeployagent-setup ] ; then
  # awscli
  ./awscli-setup
  if [ -n $ACCESS_KEY ] && [ -n $ACCESS_SECRET_KEY ] && [ -n $Region ]; then
    sudo aws configure set aws_access_key_id $ACCESS_KEY
    sudo aws configure set aws_secret_access_key $ACCESS_SECRET_KEY
    sudo aws configure set default.region $Region

    # copy to root use
    sudo cp -R ~/.aws /root/
  else
    echo "Can not find the key"
  fi

  install_session_helper
  ./codedeployagent-setup
else
  echo "Oops !! lost program ... please contact the system administrator"
fi
