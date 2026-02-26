
#/usr/share/fred-mod-eppd/ssl/test-cert.pem
FINGERPRINT=$(openssl x509 -noout -fingerprint -md5 -in /usr/share/fred-mod-eppd/ssl/test-cert.pem | cut -d= -f2)


###    Configurar arcjivo server.conf e ingresar la data de conexion a la base de datos.  Igual par al demas servicios

# Initial FRED registry setup - create system registrar, your initial registrar, add EPP access, create zone etc..
# More usage can be found in manual page of fred-admin

# You can name the system registrar as you want - but then dont forget to change it in FRED configurations in /etc/fred/
# REG-SYSTEM is the default one
/usr/sbin/fred-admin --registrar_add --handle=REG-SYSTEM --reg_name=REG-SYSTEM --organization=SYSTEM --street1=SYSTEM --city=SYSTEM --email=SYSTEM --url=SYSTEM --country=CZ --dic=12345 --no_vat --system

# Create your registrar that will be used to register domains, contacts, nssets etc..
#fred-admin --registrar_add --handle "REG-NIC" --country "CR" --ico "123456789" --reg_name "REG-NICR" --organization "NICCR" --street1 "San Jose" --city "San Jose" --postalcode "1489" --telephone "+506.123456789" --email "ti@nic.vr" --url "https://nic.cr" --dic "DEMO12345678" --system

# Add EPP access to your registrar
# Please change the certificate used to your own generated certificate(authority used to generate the certificate needs to be configured on EPP node - as shown below)
# Also the password should be something strong - max. 16 chars
# Fingerprint of certificate can be obtained via `openssl x509 -noout -fingerprint -md5 -in /path/to/cert.crt`
#fred-admin --registrar_acl_add --handle REG-YOUR_HANDLE --certificate "Certificate MD5 fingerprint" --password 12345678
#fred-admin --registrar_acl_add --handle REG-NIC --certificate "$FINGERPRINT"  --password 12345678

# Create zone you want to manage using FRED
#fred-admin --zone_add --zone_fqdn=<zone> --hostmaster hostmaster@domain.something \
#        --ns_fqdn some.ns.test.something
#fred-admin --zone_ns_add --zone_fqdn=<zone> --ns_fqdn=other.ns.test.something

# Ensure the log files are created
#touch /var/log/fred-zone-services.log
#chown fred /var/log/fred-zone-services.log

# Restart all of the Fred daemons
#systemctl restart 'fred-*'

# Mask services not included in public release(they are not usable)
#systemctl mask fred-auction-warehouse
#systemctl mask fred-dbreport-services
#rm /lib/systemd/system/fred-auction-warehouse.service
#systemctl reset-failed

# If any of the services are failing to start, you can debug them using manual run, for example if you want to debug why `fred-backend-logger.service` is not starting use: `sudo -u fred fred-logger-services --config /etc/fred/fred-logger-services.conf` - it will show you what's wrong