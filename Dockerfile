FROM python:3
ADD align.py /
RUN pip install click edlib
