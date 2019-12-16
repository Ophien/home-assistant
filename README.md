[singularitynet-home]: https://www.singularitynet.io
[author-home]: http://alysson.thegeneralsolution.com

# home-assistant-scheme-api

This repository contains a home assistant Scheme API, which allows calling for services available on each of the existing smart devices connected in the Home Assistant.

# get started

You need to have a Guile environment to run Scheme scripts, the Home Assistant Server installed, and at least one smart device to use the Home Assistant Scheme API.  This API was tested on a Ubunto 18.04.

## Installing the Guile environment

You can install guile with the following steps.

1) Download guile
```
ftp://ftp.gnu.org/gnu/guile/guile-2.2.6.tar.gz
```
2) Unpack

```
zcat guile-2.2.6.tar.gz | tar xvf -
```

3) Install

```
cd guile-2.2.6
./configure
make
make install    
```

## Installing the Home Assistant

To install the Home Assistant, make sure that you have python 3.x, build-essential, and ssh installed.

Run the following command to install the Home Assistant

```
sudo pip3 install homeassistant
```

# Adding a Device: Special Case

As a basic example, I am going to show how to add a Yeeligh bulb, since it involves a manual procedure that may be required to some devices. For all the others, it is most likely for the Home Assistant to detect them automatically.

Do the following to allow the Home Assistant to see your device.

1) Connect the Yeelight bulb into the same network as your Home Assistant server by following its manual. You will likely need to install a Yeelight app on your smartphone. 
2) Add the following lines to the end of the Home Assistant *configuration.yml* file locate in */home/***your user***/.homeassistant/* 

```
yeelight:
  devices:
     x.x.x.x:
      name: Office
```
Where *x.x.x.x* is the IPv4 address of your Yeelight Bulb.

3) Save and close the file.
4) Make sure that your Yeelight bulb device has the Lan mode enabled in the Yeelight app.

# Running the Home Assistant server

the Home Assistant server can be run with the following.

```
hass --open-ui --log-file hass.log
```

This command will run the Home Assistant server, with the UI support, and will save the logs from the server in the *hass.log* file.

## Obtaining an access token to be able to perform command line calls to the Home Assistant server

The access token is an essential part of your Home Assistant server, it will allow you to call for services from the service that can manipulate your connected devices.

Do the following to generate an access token.

1) Open a Home Assistant server.
2) Enter its UI by typing localhost/8123 in a web-browser of your preference.

    * The first time you, it will ask you to create a new account. After creating the account, log-in to the system and do the following.

3) Click on your user name at the bottom of the left menu tab.
4) Scroll down to the bottom of the content and you will see a section called ***Long-Lived Access Tokens***.
5) Click *create token* and give it a name.
6) Copy the token that will be shown to you.

    * keep that token because it is most likely that you will not be able to see it again.

## Getting your Yeelight entity ID

 An entity ID is necessary to send a command to any device, thus for our use case you need to get the entity ID of the connected Yeelight. 
 
 Entity IDs usually posses the form ***domain.entity***. To see all the available IDs click on the ***configuration*** button on the bottom of the left menu and then go to the ***entities*** section. 
 
In case your entity ID is not being shown there, try to get it from the ***overview*** view by clicking in the ***overview*** button on the top of the left menu.

# Using the Scheme API

Use the commands bellow to call the Home Assistant server through the Scheme API.

1) clone ***https://github.com/Ophien/home-assistant.git***
1) Open a Guile environment by typing ***guile*** inside the ***home-assistant/api*** folder in a terminal.
2) With the Guile environment running, use the following commands to load the modules, set the server address, and access token.

```
(load "hass.scm")
(load-modules (hass-services-api))
(hass-set-server-adress "IPv4 server address")
(hass-set-token 'Long-Lived Access Tokens)
```

Where ***IPv4 server address*** is your server IPv4 address and ***Long-Lived Access Tokens*** is your previously generated access token.

3) Call the ***turn_on*** command from the configured Yeelight device from this Readme.

```
(hass-call-service ***domain*** ***entity*** ***command***)
```

* Where, the *domain* is the first name of the Yeelight entity ID, *entity* is the second one, and ***command*** is the service to be called. For example, if your Yeelight has the entity ID ***light.office*** in your Home Assistant, then your *domain* is ***light*** and your entity is ***office***. The aforementioned example can be called with the command below.

```
(hass-call-service "light" "office" "turn_on")
```

# Author

[Alysson Ribeiro da Silva][author-home] - *Maintainer* - [SingularityNET][singularitynet-home]