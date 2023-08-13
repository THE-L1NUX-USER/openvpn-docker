#!/bin/bash

function datef() {
    # Output:
    # Sat Jun  8 20:29:08 2019
    date "+%a %b %-d %T %Y"
}

# Generate a random alphanumeric string of given length
function generateRandomString() {
    local length="$1"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Generate a new client configuration
function createConfig() {
    cd "$APP_PERSIST_DIR"
    
    # Generate a random client ID
    CLIENT_ID=$(generateRandomString 32)
    CLIENT_PATH="$APP_PERSIST_DIR/clients/$CLIENT_ID"
    
    # Redirect stderr to the black hole
    easyrsa build-client-full "$CLIENT_ID" nopass &> /dev/null
    # Writing new private key to '/usr/share/easy-rsa/pki/private/client.key
    # Client certificate /usr/share/easy-rsa/pki/issued/client.crt
    # CA certificate by the path /usr/share/easy-rsa/pki/ca.crt
    
    mkdir -p "$CLIENT_PATH"
    
    cp "pki/private/$CLIENT_ID.key" "pki/issued/$CLIENT_ID.crt" pki/ca.crt /etc/openvpn/ta.key "$CLIENT_PATH"
    
    cd "$APP_INSTALL_PATH"
    cp config/client.ovpn "$CLIENT_PATH"
    
    echo -e "\nremote $HOST_ADDR $HOST_TUN_PORT" >> "$CLIENT_PATH/client.ovpn"
    
    # Embed client authentication files into config file
    cat <(echo -e '<ca>') \
        "$CLIENT_PATH/ca.crt" <(echo -e '</ca>\n<cert>') \
        "$CLIENT_PATH/$CLIENT_ID.crt" <(echo -e '</cert>\n<key>') \
        "$CLIENT_PATH/$CLIENT_ID.key" <(echo -e '</key>\n<tls-auth>') \
        "$CLIENT_PATH/ta.key" <(echo -e '</tls-auth>') \
        >> "$CLIENT_PATH/client.ovpn"
    
    # Append client ID info to the config
    echo ";client-id $CLIENT_ID" >> "$CLIENT_PATH/client.ovpn"
    
    echo "$CLIENT_PATH"
}

# Zip files without password protection
function zipFiles() {
    local CLIENT_PATH="$1"
    local IS_QUIET="$2"
    
    # -q to silence zip output
    # -j junk directories
    zip -q -j "$CLIENT_PATH/client.zip" "$CLIENT_PATH/client.ovpn"
    if [ "$IS_QUIET" != "-q" ]; then
       echo "$(datef) $CLIENT_PATH/client.zip file has been generated"
    fi
}

# Zip files with password protection
function zipFilesWithPassword() {
    local CLIENT_PATH="$1"
    local ZIP_PASSWORD="$2"
    local IS_QUIET="$3"
    # -q to silence zip output
    # -j junk directories
    # -P pswd use standard encryption, password is pswd
    zip -q -j -P "$ZIP_PASSWORD" "$CLIENT_PATH/client.zip" "$CLIENT_PATH/client.ovpn"

    if [ "$IS_QUIET" != "-q" ]; then
       echo "$(datef) $CLIENT_PATH/client.zip with password protection has been generated"
    fi
}

# Remove client configuration
function removeConfig() {
    local CLIENT_ID="$1"
    
    cd "$APP_PERSIST_DIR"
    
    easyrsa revoke "$CLIENT_ID" << EOF
yes
EOF
    easyrsa gen-crl
    
    cp /opt/openvpn_data/pki/crl.pem /etc/openvpn
    
    cd "$APP_INSTALL_PATH"
}

