import requests
import time
massive=['3250','3637','3655','952','280','948','2916','950','334','3241','490']
for item in massive:
    response = requests.post('https://forpost.dtln.ru/system-api/SetCameraStreamer', data = {'AdminLogin':'логин','AdminPassword':'пароль','StreamerID':'8', 'CameraID':item}, headers = {'Content-Type':'application/x-www-form-urlencoded'})
    print(response.request.body)
    print(response)
    time.sleep(5)
