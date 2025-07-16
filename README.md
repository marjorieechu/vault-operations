# vault-operations

Automated backup of HashiCorp Vault data to AWS S3 using a Bash script for secure and reliable recovery

A bash shell script was written to back up vaults in simple file storage in a designated directory.
this because sentinel vault runs in file mode and not raft mode.
The directory is created if it doesnt exist and has backups saved with time stamp while also saving backup logs.
A CI was written to run this script at a weekly interval and upload these backups in an s3 bucket as tar files.
an s3 bucket was provisioned using terraform first in the sandbox account and then in the stage account.
Its name was saved as a secret variable in github actions alongside the AWS stage account login details.
this was resorted to because fetching the aws credentials from vault at run time gave series of errors probably because
vault was stopped and restarted at various steps in the CI, although this was a necessity.
The CI ran successfully at test and the s3 bucket was confirmed to contain the backup file at console.
