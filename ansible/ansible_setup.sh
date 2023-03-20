#!/bin/bash
ansible-galaxy install -r requirements.yml
python3 -m pip install -r requirements.txt --upgrade