import psutil
from pushbullet import Pushbullet
import time
import socket

API_KEY = '<Your API KEY>'

pb = Pushbullet(API_KEY)

def check_internet_connection():
    try:
        socket.create_connection(("8.8.8.8", 53), timeout=3)
        return True
    except OSError:
        pass
    return False

def check_battery_level():
    battery = psutil.sensors_battery()
    message=f"Battery at {battery.percent:.0f}%"
    if battery.percent > 90 and battery.power_plugged:
        pb.push_note(f"Laptop Battery 90",message)
        time.sleep(3000)
    elif battery.percent < 30 and not battery.power_plugged:
        pb.push_note("Laptop Battery Low",message)

while True:
    if check_internet_connection():
        check_battery_level()
        time.sleep(200) 
    else:
        time.sleep(300)
