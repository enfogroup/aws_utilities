# awsp

## Pre-reqs
- AWS CLI
    - Windows:
        - Download from [docs.aws.mazon.com/cli](https://docs.aws.amazon.com/cli/latest/userguide/install-windows.html)
    - Linux:
        - sudo apt-get install python-pip
        - pip install awscli --upgrade --user
- Clone https://bitbucket.org/emanYourProfile/aws_utilities
    - Windows: use `awsp.cmd` in `awsp_windows`.
    - Mac/Linux: modify `.bashrc`: `. <path to aws_aliases>`
- Create access keys in AWS.
    - AWS root account -> IAM -> Users -> Security Credentials -> Generate Access key
- Modify the configuration files:
    - Windows: `C:\Users\<name>\.aws\credentials` and `config`.
    - Mac/Linux: `~/.aws/credentials` and `config`.

### Config
```[profile YourProfile]
output = json
region = eu-west-1
mfa_serial = arn:aws:iam::123456789012:mfa/user_account_name

[default]
region = eu-west-1

[profile some-project]
region = eu-west-1
role_arn = arn:aws:iam::123456789012:role/Your-Role
source_profile = YourProfile-temp
output = json
```
### Credentials
```
[some-project]
region = eu-west-1
role_arn = arn:aws:iam::123456789012:role/Your-Role
source_profile = YourProfile-temp
output = json

[YourProfile]
aws_access_key_id=<the key you created earlier>
aws_secret_access_key=<the key you created earlier>
```
Change `YourProfile` to a name of your choosing.

## Usage
- `awsp <your base profile> <mfa code>`, example: `awsp daniel 123456`.
- `aws s3 ls` (should give access denied)
- `aws s3 ls --profile <profile name>` (should work)
- `awsp <profile>`, example: `awsp some-project`
