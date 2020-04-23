@ECHO OFF
set profile=%1
echo profile: %profile%
set /p test="value: "
echo test: %test%
aws configure set aws_access_key_id %test% --profile %profile%-temp
