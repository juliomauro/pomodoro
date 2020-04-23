#!/bin/bash
# pomodoro.sh
# Julio Mauro <julio.mauro@g...com>
#
WORKTIME="1500"
BREAKTIME="300"

while true
do
        notify-send 'Pomodoro: Focus on your task' --icon=dialog-information
	echo "Pomodoro: Focus on your task"
	play sound/work.mp3  > /dev/null 2>&1
        echo "work: `date`" >> /tmp/pomodoro.log
        sleep $WORKTIME
        notify-send 'Pomodoro: Take a brake' --icon=dialog-information
	echo "Pomodoro: Take a brake"
	play sound/break.mp3  > /dev/null 2>&1
        echo "break: `date`" >> /tmp/pomodoro.log
        sleep $BREAKTIME
done
