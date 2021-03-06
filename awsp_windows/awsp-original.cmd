@ECHO OFF

SETLOCAL ENABLEEXTENSIONS EnableDelayedExpansion
SET me=%~n0

set profile=%1
if [%1]==[] set profile=YourProfile

for /F %%F in ('aws configure get role_arn --profile %profile%') do set role_arn=%%F
echo role_arn: %role_arn%
for /F %%F in ('aws configure get aws_access_key_id --profile %profile%') do set key_exists=%%F
echo key_exists: %key_exists%
for /F %%F in ('aws configure get mfa_serial --profile %profile%') do set mfa_serial=%%F
echo mfa_serial: %mfa_serial%

IF DEFINED key_exists (
	echo profile: %profile%
	IF DEFINED mfa_serial (
		set /p mfa_token="Enter a MFA token: "
		for /F "tokens=1,2,3" %%a in ('aws sts get-session-token --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --serial-number !mfa_serial! --token-code !mfa_token! --output text --profile !profile!') do (
			set access_key_id=%%a
			set secret_access_key=%%b
			set session_token=%%c
		)
		aws configure set aws_access_key_id !access_key_id! --profile !profile!-temp
		aws configure set aws_secret_access_key !secret_access_key! --profile !profile!-temp
		aws configure set aws_session_token !session_token! --profile !profile!-temp
		aws configure set default.aws_access_key_id !access_key_id!
		aws configure set default.aws_secret_access_key !secret_access_key!
		aws configure set default.aws_session_token !session_token!
		echo Enabled temporary session for profile !profile! as default and !profile!-temp
	) 
) ELSE IF DEFINED role_arn (
	for /F %%F in ('aws configure get source_profile --profile %profile%') do set source_profile=%%F
	echo source_profile: !source_profile!
	for /F %%F in ('aws iam get-user --query User.UserName --output text --profile !source_profile!') do set role_session_name=%%F
	echo role_session_name: cli-!role_session_name!
	for /F %%F in ('aws configure get mfa_serial --profile !source_profile!') do set mfa_serial=%%F
	echo mfa_serial: !mfa_serial!
	IF DEFINED mfa_serial (
		set /p mfa_token="Enter a MFA token: "
		for /F "tokens=1,2,3" %%a in ('aws sts assume-role --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --role-arn !role_arn! --role-session-name cli-!role_session_name! --serial-number !mfa_serial! --token-code !mfa_token! --duration-seconds 43200 --profile !source_profile! --output text') do (
			set access_key_id=%%a
			set secret_access_key=%%b
			set session_token=%%c
		)
	) ELSE (
		for /F "tokens=1,2,3" %%a in ('aws sts assume-role --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" --role-arn !role_arn! --role-session-name cli-!role_session_name! --profile !source_profile! --output text') do (
			set access_key_id=%%a
			set secret_access_key=%%b
			set session_token=%%c
		)
	)
	aws configure set default.aws_access_key_id !access_key_id!
	aws configure set default.aws_secret_access_key !secret_access_key!
	aws configure set default.aws_session_token !session_token!
	echo Enabled temporary session for profile !profile! as default
)