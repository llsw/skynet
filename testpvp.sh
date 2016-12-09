#!/bin/bash
ans=0
for i in {1..9}
do
    nohup 3rd/lua/lua sprj/client/sclient.lua &
done
