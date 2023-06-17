# Terraform S3 bucket
Terraform scripts to create s3 bucket

# How do I generate ssh RSA keys under Linux operating systems?

You need to use the ssh-keygen command as follows to generate RSA keys (open terminal and type the following command):
```
ssh-keygen -t rsa
```
OR
```
ssh-keygen
```

Sample outputs:

```
Enter file in which to save the key (/home/dj/.ssh/id_rsa): 
Created directory '/home/dj/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/dj/.ssh/id_rsa.
Your public key has been saved in /home/dj/.ssh/id_rsa.pub.
The key fingerprint is:
58:3a:80:a5:df:17:b0:af:4f:90:07:c5:3c:01:50:c2 dj@dj-notebook
```

Here, "id_rsa.pub" is public key and "id_rsa" is private key. You can rename these two files with your choice of name. In my case, I had named them as "terraform-key.pub" and "terraform-key". 

# Accessing the server using private key.

i) Run the following command to change the file permissions to 600 to secure the key. You can also set them to 400. This step is required:
```
chmod 600 terraform-key
```
ii) Use the key to log in to the SSH client as shown in the following example, which loads the key in file deployment_key.txt, and logs in as user demo to IP <ip-address>:
```
ssh -i terraform-key demo@<ip-address>
```
