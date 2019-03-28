## Local Development

### Dependencies

Install virtualenv burrito

```
curl -sL https://raw.githubusercontent.com/brainsik/virtualenv-burrito/master/virtualenv-burrito.sh | $SHELL
```

Make a virtual env

```bash
mkvirtualenv wasmerspeed -p /usr/local/bin/python3
```

Install local packages

```bash
pip install -r requirements.txt
```

### Migrations

Make migrations (to bring the db up to date with any changes on the models)

```bash
python manage.py makemigrations
```

Run migrations (to apply the migrations in the db)

```bash
python manage.py migrate
```

### Run Server

Run Django in development mode:

```bash
python manage.py runserver
```


# Kubernetes


## Certificates

Following the docs here: https://estl.tech/configuring-https-to-a-web-service-on-google-kubernetes-engine-2d71849520d


```
# Generate Certificates
certbot -d speed.wasmer.io --manual --logs-dir certbot --config-dir certbot --work-dir certbot --preferred-challenges dns certonly
# Cert
cat certbot/live/speed.wasmer.io/fullchain.pem | base64 | pbcopy
# Key
cat certbot/live/speed.wasmer.io/privkey.pem | base64 | pbcopy

# Update sslcerts.yaml with the results
kubectl apply -f secrets/sslcerts.yaml
kubectl apply -f ingress.yaml
```
