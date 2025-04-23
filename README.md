```
Electro is a Telegram bot that retrieves intervals of cheap power from  PRE.
```

## Other App Versions

```
Main branch contains containirised version of this bot, 
Check the branch "original" for a simple desktop application
```

## Containerized solutions

```
Inside ./containers directory there is implementation for Docker compose. in ./charts directory you will find a Helm chart.
```

### Build the container
You can change the name of the container in the whole project
```
docker build -t ilyassakhanov/my-app
```

## Install
### Telegram Bot setup
If you want to set up a similar Telegram bot then you need to follow instructions on [how to set up your bot](https://core.telegram.org/bots/tutorial)

### Credentials & config creation
After recieving your credentials, create your own credentials.json and config.yaml in these locations:
- charts/my-app/templates/config.yaml
- charts/my-app/templates/credentials.json

### Deploy

```
helm install my-app charts/my-app -n my-app --create-namespace
```

## Uninstall
```
helm uninstall my-app -n my-app
```