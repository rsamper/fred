#!/bin/bash

DB_PASSWORD="123"

#sudo -u postgres psql -c "CREATE USER fred WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
#sudo -u postgres psql -c "CREATE USER logd WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"

function pause(){
 read -s -n 1 -p "Press any key to continue . . ."
 echo ""
}
clear
echo "========================================"
echo "FRED CZ 2026.1 FRED Installaer -  NIC CR"
echo "========================================"
sleep 3


echo "1/5. Instalando prerequisitos..."
echo "========================================"
sleep 3
# OS is up to you, postgresql 17 is required

apt update
apt install -y ca-certificates curl gnupg lsb-release git sudo
sleep 2



clear
echo "2/5. Clonando repositorio..."
echo "========================================"


# Clone repo with configurations(.sql structures of databases)
cd /tmp/
git clone https://gitlab.nic.cz/fred/demo-install.git
slep 3

clear
echo "Moviento carpeta files..."
echo "========================================"
sleep 2

# Move conf files to /tmp
mv demo-install/files /tmp/


clear
echo "3/5. Instalando Postgres..."
echo "========================================"
sleep 3

# Install postgresql 17
echo "Configurando repositio Postgres..."
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list

echo "Instalando Postgres..."

apt update
apt -y install postgresql-17 postgresql-client-17

echo "Configurando Postgres..."
# Set psql timezone to UTC, set correct listen addresses and setup pg_hba correctly
sed -i~ -e "s/^#\?\s*timezone\s*=.*/timezone = 'UTC'/" /etc/postgresql/17/main/postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/17/main/postgresql.conf
systemctl restart postgresql

clear
echo "4/5.Inicializando Base de datos FRED.... "
echo "========================================"
sleep 3


# Initialize fred and fredlog database
mkdir -p /var/lib/postgresql/17/fred
cp -r files/db-config/* /var/lib/postgresql/17/fred/
echo "Creando usuarios.... "
sudo -u postgres psql -c "CREATE USER fred WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c "CREATE USER logd WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"

echo "Creando bases de datos.... "
sleep 2

sudo -u postgres psql -c 'CREATE DATABASE fred;'
sudo -u postgres psql -c 'CREATE DATABASE fredlog;'

echo "Dando permisos a usuarios.... "
sleep 2

sudo -u postgres psql -c 'ALTER DATABASE fred OWNER TO fred;'
sudo -u postgres psql -c 'ALTER DATABASE fredlog OWNER TO logd;'

sudo -u postgres psql -c 'GRANT ALL PRIVILEGES ON DATABASE fred TO fred;'
sudo -u postgres psql -c 'GRANT ALL PRIVILEGES ON DATABASE fredlog TO logd;'

clear
echo "Cargando estructuras SQL .... "
sleep 2

su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U fred -d fred -f 17/fred/structure.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U fred -d fred -f 17/fred/fred_db.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U logd -d fredlog -f 17/fred/structure.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U logd -d fredlog -f 17/fred/logdb_db.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U logd -d fredlog -f 17/fred/fix-seq.sql"

clear
echo "5/5. Initialize cdnskey_processor database .... "
echo "========================================"
sleep 3

# Initialize cdnskey_processor database
sudo -u postgres psql -c "CREATE USER cdnskey_processor WITH ENCRYPTED PASSWORD '$DB_PASSWORD';"
sudo -u postgres psql -c 'CREATE DATABASE cdnskey_processor;'
sudo -u postgres psql -c 'ALTER DATABASE cdnskey_processor OWNER TO cdnskey_processor;'
sudo -u postgres psql -c 'GRANT ALL PRIVILEGES ON DATABASE cdnskey_processor TO cdnskey_processor;'

echo "Cargando estructuras cdnskey .... "
sleep 2

su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0001_schema.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0002_delete_cascade_scan_queue.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0003_enum_tables_to_enum_type.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0004_worker_name_not_null_constraint.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0005_scan_results_indexes.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0006_get_raw_scan_results.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0007_split_scan_batch_table.sql"
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -f 17/fred/cdnskey/0008_scan_result_evaluation.sql"


# Add akm-worker into the cdnskey_processor database
su - postgres -c "PGPASSWORD='$DB_PASSWORD' psql -h 127.0.0.1 -U cdnskey_processor -d cdnskey_processor -c \"INSERT INTO worker (name) VALUES ('worker-1');\""

# Dont forget to configure /etc/postgresql/17/main/pg_hba.conf with correct ip addresses
clear 
echo "========================================================================================"
echo "Dont forget to configure /etc/postgresql/17/main/pg_hba.conf with correct ip addresses"
echo "========================================================================================"
sleep 3
echo "Fin"
exit 0