#!/bin/bash
# Etherpad-lite with apache on debian
# mod_proxy, mod_proxy_http, mod_headers, proxy_wstunnel, mod_deflate and mod_rewrite Apache modules.
domain="etherpad.yourdomain.org" # Domain used for this application
homedir=/home/ # folder to install etherpad.
users=username # Username use for etherpad dont use root.
myvhost="/etc/apache2/sites-enabled/etherpad_$domain.conf" # Its apache2 file configuration by default.
#Install NodeJS
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs
#change folder to install etherpad
cd $homedir
git clone --branch master git://github.com/ether/etherpad-lite.git
cd etherpad-lite
chown -R $users:users $homedir

#create Vhost
/usr/bin/touch $myvhost
cat << EOF > $myvhost
<VirtualHost *:80>

    ServerAdmin postmaster@$domain
    ServerName $domain
    CustomLog /var/log/apache2/$domain_access.log combined
    ErrorLog /var/log/apache2/$domain__error.log
    LogLevel warn

    ProxyVia On
    ProxyRequests Off
    ProxyPreserveHost on
    
    <Location />
        ProxyPass http://localhost:9001/ retry=0 timeout=30
        ProxyPassReverse http://localhost:9001/
    </Location>
    <Location /socket.io>
        # This is needed to handle the websocket transport through the proxy, since
        # etherpad does not use a specific sub-folder, such as /ws/ to handle this kind of traffic.
        # Taken from https://github.com/ether/etherpad-lite/issues/2318#issuecomment-63548542
        # Thanks to beaugunderson for the semantics
        RewriteEngine On
        RewriteCond %{QUERY_STRING} transport=websocket    [NC]
        RewriteRule /(.*) ws://localhost:9001/socket.io/$1 [P,L]
        ProxyPass http://localhost:9001/socket.io retry=0 timeout=30
        ProxyPassReverse http://localhost:9001/socket.io
    </Location>

    <Proxy *>
      Options FollowSymLinks MultiViews
      AllowOverride All
      Order allow,deny
      allow from all
    </Proxy>

</VirtualHost>
<VirtualHost *:443>

    ServerAdmin postmaster@$domain
    ServerName $domain
    CustomLog /home/$username/logs/apache/$domain_access.ssl.log combined
    ErrorLog /home/$username/logs/apache/$domain_error.ssl.log
    LogLevel warn

       # SSL configuration Inser your certificates here.
       # SSLEngine on
       # SSLCertificateFile "/path/to/etherpad.domain.org/certificate.pem"
       # SSLCertificateKeyFile "/path/to/etherpad.domain.org/privatekey.pem"
        
        ProxyVia On
        ProxyRequests Off
        ProxyPreserveHost on    

        <Location />
            #AuthType Basic
            #AuthName "Welcome to the domain.org Etherpad"
            #AuthUserFile /path/to/svn.passwd
            #AuthGroupFile /path/to/svn.group
            #Require group etherpad
            ProxyPass http://localhost:9001/ retry=0 timeout=30
            ProxyPassReverse http://localhost:9001/
        </Location>
        <Location /socket.io>
            # This is needed to handle the websocket transport through the proxy, since
            # etherpad does not use a specific sub-folder, such as /ws/ to handle this kind of traffic.
            # Taken from https://github.com/ether/etherpad-lite/issues/2318#issuecomment-63548542
            # Thanks to beaugunderson for the semantics
            RewriteEngine On
            RewriteCond %{QUERY_STRING} transport=websocket    [NC]
            RewriteRule /(.*) ws://localhost:9001/socket.io/$1 [P,L]
            ProxyPass http://localhost:9001/socket.io retry=0 timeout=30
            ProxyPassReverse http://localhost:9001/socket.io
        </Location>
        
        <Proxy *>
            Options FollowSymLinks MultiViews
            AllowOverride All
            Order allow,deny
            allow from all
        </Proxy>

</VirtualHost>
EOF
/etc/init.d/apache2 restart

#Running APP 
echo "To execute application  : ./$homedir/etherpad-lite/bin/run.sh"
echo "Change certificates in $myvhost"
