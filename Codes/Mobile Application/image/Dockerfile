# start by pulling the python image
FROM ubuntu
FROM python:3.11

# copy the requirements file nto the image
COPY ./requirements.txt /app/requirements.txt

# switch working directory
WORKDIR /app
# Some essential tweaks

RUN pip install -U pip
# install the dependencies and packages in the requirements file
RUN /usr/local/bin/python -m pip install --upgrade pip
RUN pip install -r requirements.txt
RUN apt-get update && apt-get install ffmpeg libsm6 libxext6  -y
# copy every content from the local file to the image
COPY . /app
# EXPOSE 5000
# CMD python ./app.py

# configure the container to run in an executed manner
ENTRYPOINT [ "python" ]
# CMD ["gunicorn", "--workers=2", "--bind=0.0.0.0:5000", "app:app"]
CMD [ "./app.py",  "--host=0.0.0.0","--workers=2"]

# CMD ["gunicorn","--workers=2","app:app" ]