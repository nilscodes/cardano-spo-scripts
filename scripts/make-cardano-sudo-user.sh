#!/bin/bash

sudo useradd -m cardano -s /bin/bash
sudo usermod -aG sudo cardano
sudo passwd cardano

