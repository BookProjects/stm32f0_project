import serial
import time


def main():
    ser = serial.Serial('/dev/ttyUSB0')
    print "Waiting for initial serial message"
    print ser.read()
    start_time = time.time()
    while True:
        print ser.read()
        end_time = time.time()
        print "{} ms elapsed".format((end_time - start_time) * 1000)
        start_time = end_time



if __name__ == '__main__':
    main()
