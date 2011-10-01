gpg.list_keys()[0].get('fingerprint')

## Get default key
gpg.list_keys().curkey
gpg.list_keys().curkey.get('fingerprint')

## Create stream, encrypt to new file, close stream
encrypt_stream = open('/tmp/testf.encr', 'rb')
x = gpg.encrypt_file(encrypt_stream,encrypt_for,armor=True,output='/tmp/testf.encr.o')
encrypt_stream.close()