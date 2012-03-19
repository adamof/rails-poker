#!/bin/sh
nohup rails s &
nohup ../../redis-2.4.8/src/redis-server &
nohup juggernaut &
nohup ./script/listener &
