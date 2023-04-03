# che-demo-app

```bash
curl -X POST localhost:8080/random-thoughts/save-thought -H 'Content-Type: application/json' -d "{\"thoughtId\":\"$(uuidgen)\",\"randomThought\":\"Hello Quarkus\"}"

curl localhost:8080/random-thoughts/thoughts
```
