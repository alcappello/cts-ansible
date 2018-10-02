# Ansible @ CTS

This is the sample code that I prepared for the [Cygni Tech Summit](https://cts.cygni.se) in Stockholm (14/09/2018).
Please feel free to clone this repo, install Ansible and play with the code. Don't forget to shut down all the EC2 instances when you're done! :)

## How to install Ansible

Follow the instructions on [Ansible's website](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) to install it on your system.
For MacOS users, `pip` is the easiest way:

```
sudo pip install ansible
```

## Install the dependencies

In order to run the playbooks on this repo, you need to install two dependencies (their reference is found on the file called `requirements.yml`).
Run the following on your favorite terminal, inside the repo's folder:

```
ansible-galaxy install -r requirements.yml
```

Now you would be able to run the two playbooks that I've created. The data in `vars/aws.yml` is specific for my account (don't be too excited, no passwords there!): if you want to test that playbook, then edit the file and change the variables with proper values.
Then simply run:

```
ansible-playbook aws.yml
ansible-playbook new-developer.yml
```
