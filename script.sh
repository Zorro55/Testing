#!bin/bash
userName=roberto.viquez  #create a user
aws iam create-user --user-name $userName | grep "UserName" | tr -d '[:space:]' >>  user.txt 

userToGroup=roberto.viquez     #adding user to group
addToGroup=vendor.basic
aws iam add-user-to-group --user-name $userToGroup --group-name $addToGroup

codecommit=repository         #creating a repository and description
description="Sum"
aws codecommit create-repository --repository-name $codecommit --repository-description $description | grep  "cloneUrlHttp" | tr -d '[:space:]' >> user.txt 

policy=arn:aws:iam::aws:policy/AWSCodeCommitPowerUser   #set policy to user
polUser=roberto.viquez
aws iam attach-user-policy --policy-arn $policy --user-name $polUser

attGrPolArn=arn:aws:iam::aws:policy/AWSCodeCommitPowerUser   #set policy to group
grName=vendor.basic
aws iam attach-group-policy --policy-arn $attGrPolArn --group-name $grName | 

userName=roberto.viquez     #generating service name and service password to code commit 
serviceName=codecommit.amazonaws.com
aws iam create-service-specific-credential --user-name $userName --service-name $serviceName | grep -E '"ServiceUserName"|"ServicePassword"' | sort -r | tr -d '[:space:]' | sed 's/.$//' >> user.txt

sed -i ''s/\"//g'' user.txt
cat user.txt | sed -ri 's/ServicePassword/,&/' user.txt
cat user.txt | sed "s/.*\(....$\)/\1/" > last.txt 
cat user.txt | sed -i 's/....$//' user.txt
cat user.txt | sed -ri 's/','+/<br>/g' user.txt

escape_json_for_sed() {
    sed 's/\\/\\&/g; s/[&/\]/\\&/g; s/"/\\\\&/g'
}

sed 's/"Data": "user-data"/"Data": "'"$(head -1 user.txt | escape_json_for_sed)"'"/g'  messageTemp.json > message.json

aws ses send-email --from Zorro55@gmail.com --destination file://c:/temp/destination.json --message file://c:/temp/message.json

#send a password symbols via sms 

aws sns subscribe --topic-arn arn:aws:sns:eu-west-1:701177775058:SendAPassword --protocol sms --notification-endpoint +37068494451
aws sns publish --topic-arn arn:aws:sns:eu-west-1:701177775058:SendAPassword --message file://c:/temp/last.txt

$SHELL



