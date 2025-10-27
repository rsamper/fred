======. MAC
 brew install qemu
 brew install binfmt-support

The error "no matching manifest for linux/arm64/v8" in Docker on macOS with Apple Silicon indicates that you're trying to pull an image built for the x86 architecture (like amd64/ubuntu:20.04), which is not natively compatible with your M1 chip's arm64 architecture. 
Here's how to resolve this:
1. Utilize a Multi-Platform Image or Build a Native Image:
Check for ARM64 Support:
Some images are multi-platform, meaning they have versions for both x86 and arm64. Check the image's page on Docker Hub or its documentation to see if an arm64 version exists. 
Build Your Own:
If the image doesn't have an ARM64 version, you can build a custom image from a Dockerfile that targets linux/arm64. 
Consider a Native Image:
When possible, using a native image (one built for the arm64 architecture) will offer better performance and compatibility compared to using an x86 image with emulation. 
2. Use the --platform flag (Emulation): 
You can run an x86 image on your arm64 machine by specifying the --platform flag during the docker run or docker build commands: 
Código

    docker run --platform linux/amd64 <image_name>
    docker build --platform linux/amd64 .
This will instruct Docker to emulate the x86 architecture. 
QEMU: For this to work, you might need to install QEMU:
Código

    brew install qemu
    brew install binfmt-support
    sudo chmod +x /usr/local/bin/qemu-user-static
========

 docker run -d --name topdemo alpine top -b
 docker attach topdemo

docker run -d  --name nic-fred-client -v /Users/rsamper/Dev/docker/postgres12:/var/lib/po ubuntu:20.04

docker run -d  --name nic-fred-client ubuntu:20.04 /bin/bash
    docker run --platform linux/amd64 ubuntu:20.04 /bin/bash
-d, --detach		Run container in background and print container ID

docker commit <container_id> [REPOSITORY[:TAG]]
docker commit d2a4f01a9976 myimage:v1

apt update
apt install ca-certificates curl gnupg lsb-release -y
apt install python3-dnspython python3-pip uwsgi-plugin-python3 postgresql-client -y
mkdir -p /usr/share/keyrings/
apt install wget
wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg
cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
apt update
apt install pgbouncer cdnskey-scanner -y

apt install python3-pydantic python3-fred-epplib python3-django-secretary

apt install fred-client -y
mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

echo "Favor dirigirse a /etc/fred"
echo "Y modificar/crear archivos de configuracion"
echo "Ademas sustituir ip del servidor de base de datos y clave de la base de datos de fred"
cd /etc/fred

ETETETE
=======

docker run -it --name nic --platform linux/amd64 -v /Users/rsamper/Dev/docker/fred:/etc/fred ubuntu:20.04 /bin/bash

docker commit d2a4f01a9976 myimage:v1

-v /Users/rsamper/Dev/docker/fred:/etc/fred


docker run -it --name nic_fredclient --platform linux/amd64 -v /Users/rsamper/Dev/docker/fred:/etc/fred myimage:v1 fred-client