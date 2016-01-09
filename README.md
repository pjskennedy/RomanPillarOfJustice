# Roman Pillar of Justice

# Disclaimer
This application was hacked together in a day for PagerDuty's HackDay Competition. The code is not meant to be resilient, reliable, good looking, or even functional. As I write this, the code _might_ work. I basically pieced pieces of code together until it worked. This means bad code, I apologize in advance, I'm not going to invest time fixing it.
You can see my panicked comments through the code trying to validate why I made horrible decisions.

This project has two components, The web-app (deployed to Heroku) and the Pillar of Justice (runs on a raspberry pi).

To run the missile launcher:

```
$ # checkout the code
$ bundle install
$ MISSILEQUEUE_BASE_URL='heroku url from application' CAMERA_ID='camera id' rake run_missile
```
