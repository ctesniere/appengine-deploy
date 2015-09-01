# appengine-deploy

```sh
# In your .bash_profile file :
function appengine-deploy() {
    source <(curl -s https://raw.githubusercontent.com/ctesniere/appengine-deploy/master/appengine-deploy.sh)
    messageSuccess "Downloaded Script"
    appengineDeploy $1 $2
}
```
