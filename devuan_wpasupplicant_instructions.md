######  INSTRUCCIONES WPA_SUPPLICANT ######

1º sudo iw dev (encontrar adaptadores de wifi disponibles)

2º sudo ip link show wlan0 (ver el estado del dispositivo. link/ether es la MAC address)

3º sudo ip link set wlan0 up (activar la interfase wifi)

4º sudo iw wlan0 link (ver el estado de la conexión)

5º sudo iw wlan0 scan (buscar redes wifi y tomar el SSID y si es WPA/WPA2=RSN o WEP)

6º sudo wpa_passphrase nombreDelSSID >> /etc/wpa_supplicant.conf (enter y luego poner password)
   escribirPasswordDelWifi (y así se crea un archivo de configuración con el password)

7º cat /etc/wpa_supplicant.conf (ver cómo quedó el archivo)

8º sudo wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant.conf (conectarse al wifi WPA/WPA2)

9º sudo iw wlan0 link (ver el estado de la conexión)

10º sudo dhclient wlan0 (obtener una IP)

11º sudo ip addr show wlan0 (ver la IP asignada en el dato 'inet')

12º sudo ifconfig wlan0 (otra forma de ver la IP en 'inet addr')

13º sudo ip route show (verificar misma IP en 'link src ...')

14º ping -c 7 torproject.org (verificar conexión con 7 pings)



## iwd alternative

 * https://linuxconfig.org/how-to-manage-wireless-connections-using-iwd-on-linux

```
iwctl device list
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect MyFibra06 --passphrase mysupersecretpassphrase
iwctl station wlan0 show
```

 * We can see the connection is now active; however, if we try to navigate to some location, or just ping an external address, we fail. Why? That is because although we connected to the access point, we didn’t assign an IP address to the interface, and we didn’t setup a gateway for it, nor a dns server address. We can set those parameters statically or we can get it from the dhcp server integrated in our router. In this case we will use the latter option.
 
 * To obtain a dhcp configuration on Linux, we usually use a client like dhcpcd; Iwd, however, has a dhcp client integrated, which is disabled by default. To activate it we need to enter the following lines in the iwd configuration file: /etc/iwd/main.conf (the file may not exists by default):

```
[General]
EnableNetworkConfiguration=true
```

```
iwctl station wlan0 disconnect
iwctl known-networks list
iwctl known-networks MyFibra06 forget
```


